#include "mixer/playermanager.h"

#include <QRegularExpression>

#include "audio/types.h"
#include "control/controlobject.h"
#include "effects/effectsmanager.h"
#include "engine/channels/enginedeck.h"
#include "engine/enginemixer.h"
#include "library/library.h"
#include "library/trackcollectionmanager.h"
#include "mixer/auxiliary.h"
#include "mixer/deck.h"
#include "mixer/microphone.h"
#include "mixer/previewdeck.h"
#include "mixer/sampler.h"
#include "mixer/samplerbank.h"
#include "moc_playermanager.cpp"
#include "preferences/dialog/dlgprefdeck.h"
#include "soundio/soundmanager.h"
#include "track/track.h"
#include "util/assert.h"
#include "util/compatibility/qatomic.h"
#include "util/defs.h"
#include "util/logger.h"

namespace {

const mixxx::Logger kLogger("PlayerManager");
const QString kAppGroup = QStringLiteral("[App]");
const QString kLegacyGroup = QStringLiteral("[Master]");

// Utilize half of the available cores for adhoc analysis of tracks
const int kNumberOfAnalyzerThreads = math_max(1, QThread::idealThreadCount() / 2);

const QRegularExpression kDeckRegex(QStringLiteral("^\\[Channel(\\d+)\\]$"));
const QRegularExpression kSamplerRegex(QStringLiteral("^\\[Sampler(\\d+)\\]$"));
const QRegularExpression kPreviewDeckRegex(QStringLiteral("^\\[PreviewDeck(\\d+)\\]$"));

bool extractIntFromRegex(const QRegularExpression& regex, const QString& group, int* number) {
    const QRegularExpressionMatch match = regex.match(group);
    DEBUG_ASSERT(match.isValid());
    if (!match.hasMatch()) {
        return false;
    }
    // The regex is expected to contain a single capture group with the number
    constexpr int capturedNumberIndex = 1;
    DEBUG_ASSERT(match.lastCapturedIndex() <= capturedNumberIndex);
    if (match.lastCapturedIndex() < capturedNumberIndex) {
        qWarning() << "No number found in group" << group;
        return false;
    }
    if (number) {
        const QString capturedNumber = match.captured(capturedNumberIndex);
        DEBUG_ASSERT(!capturedNumber.isNull());
        bool okay = false;
        const int numberFromMatch = capturedNumber.toInt(&okay);
        VERIFY_OR_DEBUG_ASSERT(okay) {
            return false;
        }
        *number = numberFromMatch;
    }
    return true;
}

template<class T>
T* findFirstStoppedPlayerInList(const QList<T*>& players) {
    for (T* pPlayer : players) {
        VERIFY_OR_DEBUG_ASSERT(pPlayer != nullptr) {
            continue;
        }
        ControlObject* pPlayControl = ControlObject::getControl(
                ConfigKey(pPlayer->getGroup(), "play"));
        VERIFY_OR_DEBUG_ASSERT(pPlayControl != nullptr) {
            continue;
        }
        if (!pPlayControl->toBool()) {
            return pPlayer;
        }
    }
    return nullptr;
}

inline QString getDefaultSamplerPath(UserSettingsPointer pConfig) {
    return pConfig->getSettingsPath() + QStringLiteral("/samplers.xml");
}

} // anonymous namespace

PlayerManager::PlayerManager(UserSettingsPointer pConfig,
        SoundManager* pSoundManager,
        EffectsManager* pEffectsManager,
        EngineMixer* pEngine)
        : m_mutex(QT_RECURSIVE_MUTEX_INIT),
          m_pConfig(pConfig),
          m_pLibrary(nullptr),
          m_pSoundManager(pSoundManager),
          m_pEffectsManager(pEffectsManager),
          m_pEngine(pEngine),
          // NOTE(XXX) LegacySkinParser relies on these controls being Controls
          // and not ControlProxies.
          m_pCONumDecks(std::make_unique<ControlObject>(
                  ConfigKey(kAppGroup, QStringLiteral("num_decks")), true, true)),
          m_pCONumSamplers(std::make_unique<ControlObject>(
                  ConfigKey(kAppGroup, QStringLiteral("num_samplers")), true, true)),
          m_pCONumPreviewDecks(std::make_unique<ControlObject>(
                  ConfigKey(kAppGroup, QStringLiteral("num_preview_decks")), true, true)),
          m_pCONumMicrophones(std::make_unique<ControlObject>(
                  ConfigKey(kAppGroup, QStringLiteral("num_microphones")), true, true)),
          m_pCONumAuxiliaries(std::make_unique<ControlObject>(
                  ConfigKey(kAppGroup, QStringLiteral("num_auxiliaries")), true, true)),
          m_pTrackAnalysisScheduler(TrackAnalysisScheduler::NullPointer()) {
    m_pCONumDecks->addAlias(ConfigKey(kLegacyGroup, QStringLiteral("num_decks")));
    m_pCONumDecks->connectValueChangeRequest(this,
            &PlayerManager::slotChangeNumDecks, Qt::DirectConnection);
    m_pCONumSamplers->addAlias(ConfigKey(kLegacyGroup, QStringLiteral("num_samplers")));
    m_pCONumSamplers->connectValueChangeRequest(this,
            &PlayerManager::slotChangeNumSamplers, Qt::DirectConnection);
    m_pCONumPreviewDecks->addAlias(ConfigKey(kLegacyGroup, QStringLiteral("num_preview_decks")));
    m_pCONumPreviewDecks->connectValueChangeRequest(this,
            &PlayerManager::slotChangeNumPreviewDecks, Qt::DirectConnection);
    m_pCONumMicrophones->addAlias(ConfigKey(kLegacyGroup, QStringLiteral("num_microphones")));
    m_pCONumMicrophones->connectValueChangeRequest(this,
            &PlayerManager::slotChangeNumMicrophones, Qt::DirectConnection);
    m_pCONumAuxiliaries->addAlias(ConfigKey(kLegacyGroup, QStringLiteral("num_auxiliaries")));
    m_pCONumAuxiliaries->connectValueChangeRequest(this,
            &PlayerManager::slotChangeNumAuxiliaries, Qt::DirectConnection);

    // Ensure the sampler backend exists even when a fresh Android profile has
    // no persisted [App]/num_samplers value yet. The QML skin can then bind to
    // real [Sampler1]..[Sampler8] players rather than empty control groups.
    if (m_pCONumSamplers->get() <= 0.0) {
        slotChangeNumSamplers(8.0);
    }

    // This is parented to the PlayerManager so does not need to be deleted
    m_pSamplerBank = new SamplerBank(m_pConfig, this);

    m_cloneTimer.start();
}

PlayerManager::~PlayerManager() {
    kLogger.debug() << "Destroying";

    const auto locker = lockMutex(&m_mutex);

    m_pSamplerBank->saveSamplerBankToPath(getDefaultSamplerPath(m_pConfig));
    m_players.clear();
    m_decks.clear();
    m_samplers.clear();
    m_microphones.clear();
    m_auxiliaries.clear();
    delete m_pTrackAnalysisScheduler.release();
}

void PlayerManager::bindToLibrary(Library* pLibrary) {
    m_pLibrary = pLibrary;
    const auto locker = lockMutex(&m_mutex);
    connect(pLibrary, &Library::loadTrackToPlayer, this, &PlayerManager::slotLoadTrackToPlayer);
    connect(pLibrary,
            &Library::loadTrack,
            this,
            &PlayerManager::slotLoadTrackIntoNextAvailableDeck);
    connect(this,
            &PlayerManager::loadLocationToPlayer,
            pLibrary,
            &Library::slotLoadLocationToPlayer);

    DEBUG_ASSERT(!m_pTrackAnalysisScheduler);
    m_pTrackAnalysisScheduler = pLibrary->createTrackAnalysisScheduler(
            kNumberOfAnalyzerThreads,
            AnalyzerModeFlags::WithWaveform);

    connect(m_pTrackAnalysisScheduler.get(), &TrackAnalysisScheduler::trackProgress,
            this, &PlayerManager::onTrackAnalysisProgress);
    connect(m_pTrackAnalysisScheduler.get(), &TrackAnalysisScheduler::finished,
            this, &PlayerManager::onTrackAnalysisFinished);

    foreach(Deck* pDeck, m_decks) {
        connect(pDeck, &BaseTrackPlayer::newTrackLoaded, this, &PlayerManager::slotAnalyzeTrack);
    }
    foreach(Sampler* pSampler, m_samplers) {
        connect(pSampler, &BaseTrackPlayer::newTrackLoaded, this, &PlayerManager::slotAnalyzeTrack);
    }
    foreach (PreviewDeck* pPreviewDeck, m_previewDecks) {
        connect(pPreviewDeck, &BaseTrackPlayer::newTrackLoaded, this, &PlayerManager::slotAnalyzeTrack);
    }
}
