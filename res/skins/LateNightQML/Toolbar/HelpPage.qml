import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root

    property color accentColor: "#2D8CFF"
    property color panelColor: "#15181D"
    property color panelBorderColor: "#303640"
    property color textColor: "#E8ECF2"
    property color secondaryTextColor: "#9DA6B3"
    property color warningColor: "#FFB74D"

    color: "transparent"
    radius: 8
    border.color: panelBorderColor
    border.width: 1

    ScrollView {
        id: scrollView
        anchors.fill: parent
        anchors.margins: 1
        clip: true

        ColumnLayout {
            width: Math.max(scrollView.availableWidth - 24, 520)
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 14
            topPadding: 18
            bottomPadding: 22

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Rectangle {
                    Layout.preferredWidth: 4
                    Layout.preferredHeight: 42
                    radius: 2
                    color: root.accentColor
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        Layout.fillWidth: true
                        color: root.textColor
                        font.family: "Open Sans"
                        font.pixelSize: 21
                        font.weight: Font.DemiBold
                        text: "NRave — Setup & Troubleshooting"
                    }

                    Text {
                        Layout.fillWidth: true
                        color: root.secondaryTextColor
                        font.family: "Open Sans"
                        font.pixelSize: 12
                        text: "Follow these checks in order. Items marked “first time” normally need to be done only once."
                        wrapMode: Text.WordWrap
                    }
                }

                Button {
                    Layout.preferredWidth: 74
                    Layout.preferredHeight: 30
                    text: "CLOSE"
                    onClicked: root.visible = false
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: introText.implicitHeight + 20
                color: "#1B2027"
                radius: 6
                border.color: "#303640"
                border.width: 1

                Text {
                    id: introText
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 10
                    color: root.textColor
                    font.family: "Open Sans"
                    font.pixelSize: 12
                    lineHeight: 1.25
                    text: "If the library is empty, the controller is not responding, or there is no sound, start at Step 1 and work downward. The controller setup and audio routing steps may need to be repeated whenever you reconnect a USB controller."
                    wrapMode: Text.WordWrap
                }
            }

            Text {
                Layout.fillWidth: true
                color: root.accentColor
                font.family: "Open Sans"
                font.pixelSize: 14
                font.weight: Font.DemiBold
                text: "1  ANDROID PERMISSIONS  •  FIRST TIME"
            }

            CheckBox {
                Layout.fillWidth: true
                text: "In Android Settings → Apps → NRave → Permissions, allow Music and audio."
                contentItem: Text {
                    text: parent.text
                    color: root.textColor
                    font.family: "Open Sans"
                    font.pixelSize: 12
                    leftPadding: 30
                    wrapMode: Text.WordWrap
                }
            }

            CheckBox {
                Layout.fillWidth: true
                text: "Allow Microphone when NRave asks for it. NRave declares RECORD_AUDIO because the audio engine can use microphone/audio input."
                contentItem: Text {
                    text: parent.text
                    color: root.textColor
                    font.family: "Open Sans"
                    font.pixelSize: 12
                    leftPadding: 30
                    wrapMode: Text.WordWrap
                }
            }

            CheckBox {
                Layout.fillWidth: true
                text: "If Android offers “All files access” / file access for NRave, allow it. The Android build declares MANAGE_EXTERNAL_STORAGE for its file/library workflow."
                contentItem: Text {
                    text: parent.text
                    color: root.textColor
                    font.family: "Open Sans"
                    font.pixelSize: 12
                    leftPadding: 30
                    wrapMode: Text.WordWrap
                }
            }

            CheckBox {
                Layout.fillWidth: true
                text: "Battery / power saving: set NRave to “Unrestricted” / “Don't restrict” (wording depends on the phone). Do not let Android suspend NRave during a performance."
                contentItem: Text {
                    text: parent.text
                    color: root.textColor
                    font.family: "Open Sans"
                    font.pixelSize: 12
                    leftPadding: 30
                    wrapMode: Text.WordWrap
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: permissionNote.implicitHeight + 16
                color: "#211E18"
                radius: 5

                Text {
                    id: permissionNote
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 8
                    color: root.warningColor
                    font.family: "Open Sans"
                    font.pixelSize: 11
                    text: "Why this matters: NRave's Android manifest includes READ_MEDIA_AUDIO, MANAGE_EXTERNAL_STORAGE, RECORD_AUDIO, MODIFY_AUDIO_SETTINGS, USB permission support, WAKE_LOCK and foreground-media playback permissions."
                    wrapMode: Text.WordWrap
                }
            }

            Text {
                Layout.fillWidth: true
                color: root.accentColor
                font.family: "Open Sans"
                font.pixelSize: 14
                font.weight: Font.DemiBold
                text: "2  FIRST LAUNCH  •  LIBRARY ACCESS"
            }

            CheckBox {
                Layout.fillWidth: true
                text: "On the first launch, grant the storage/files access requested by NRave."
                contentItem: Text {
                    text: parent.text
                    color: root.textColor
                    font.family: "Open Sans"
                    font.pixelSize: 12
                    leftPadding: 30
                    wrapMode: Text.WordWrap
                }
            }

            CheckBox {
                Layout.fillWidth: true
                text: "Return to the main screen and check that your music library is visible. If the library is empty, re-check the Android file/media permission before troubleshooting the controller."
                contentItem: Text {
                    text: parent.text
                    color: root.textColor
                    font.family: "Open Sans"
                    font.pixelSize: 12
                    leftPadding: 30
                    wrapMode: Text.WordWrap
                }
            }

            Text {
                Layout.fillWidth: true
                color: root.accentColor
                font.family: "Open Sans"
                font.pixelSize: 14
                font.weight: Font.DemiBold
                text: "3  CONNECT THE CONTROLLER  •  EACH USB CONNECTION"
            }

            CheckBox {
                Layout.fillWidth: true
                text: "Connect the USB controller and wait until Android detects it."
                contentItem: Text {
                    text: parent.text
                    color: root.textColor
                    font.family: "Open Sans"
                    font.pixelSize: 12
                    leftPadding: 30
                    wrapMode: Text.WordWrap
                }
            }

            CheckBox {
                Layout.fillWidth: true
                text: "Open Settings → Controllers."
                contentItem: Text {
                    text: parent.text
                    color: root.textColor
                    font.family: "Open Sans"
                    font.pixelSize: 12
                    leftPadding: 30
                }
            }

            CheckBox {
                Layout.fillWidth: true
                text: "Select the connected device as MIDI, not HID, when you want the MIDI mapping."
                contentItem: Text {
                    text: parent.text
                    color: root.textColor
                    font.family: "Open Sans"
                    font.pixelSize: 12
                    leftPadding: 30
                    wrapMode: Text.WordWrap
                }
            }

            CheckBox {
                Layout.fillWidth: true
                text: "Press Create Device. In the Mapping selector, choose your controller (for example Pioneer DDJ-FLX4). Turn On the mapping so the button becomes blue, then press Save."
                contentItem: Text {
                    text: parent.text
                    color: root.textColor
                    font.family: "Open Sans"
                    font.pixelSize: 12
                    leftPadding: 30
                    wrapMode: Text.WordWrap
                }
            }

            CheckBox {
                Layout.fillWidth: true
                text: "If Android shows a USB/audio-priority confirmation, approve it (Allow / OK). NRave needs the connected USB audio device to become the active audio device."
                contentItem: Text {
                    text: parent.text
                    color: root.textColor
                    font.family: "Open Sans"
                    font.pixelSize: 12
                    leftPadding: 30
                    wrapMode: Text.WordWrap
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: reconnectNote.implicitHeight + 16
                color: "#1B2027"
                radius: 5

                Text {
                    id: reconnectNote
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 8
                    color: root.secondaryTextColor
                    font.family: "Open Sans"
                    font.pixelSize: 11
                    text: "If NRave briefly disappears or returns to the foreground after the USB/audio device is accepted, let the transition finish. Then open Controllers again and repeat Create Device → select the same mapping → On → Save. The second save is expected in this Android connection flow."
                    wrapMode: Text.WordWrap
                }
            }

            CheckBox {
                Layout.fillWidth: true
                text: "Confirm that the controller now shows its connected/active indication before moving to Sound Hardware."
                contentItem: Text {
                    text: parent.text
                    color: root.textColor
                    font.family: "Open Sans"
                    font.pixelSize: 12
                    leftPadding: 30
                    wrapMode: Text.WordWrap
                }
            }

            Text {
                Layout.fillWidth: true
                color: root.accentColor
                font.family: "Open Sans"
                font.pixelSize: 14
                font.weight: Font.DemiBold
                text: "4  SOUND HARDWARE  •  EACH TIME YOU CONNECT AUDIO HARDWARE"
            }

            CheckBox {
                Layout.fillWidth: true
                text: "Open Settings → Sound Hardware."
                contentItem: Text {
                    text: parent.text
                    color: root.textColor
                    font.family: "Open Sans"
                    font.pixelSize: 12
                    leftPadding: 30
                }
            }

            CheckBox {
                Layout.fillWidth: true
                text: "Enable the Android audio driver."
                contentItem: Text {
                    text: parent.text
                    color: root.textColor
                    font.family: "Open Sans"
                    font.pixelSize: 12
                    leftPadding: 30
                }
            }

            CheckBox {
                Layout.fillWidth: true
                text: "Select the intended audio device / output for the connected controller. Do not leave an old or disconnected device selected."
                contentItem: Text {
                    text: parent.text
                    color: root.textColor
                    font.family: "Open Sans"
                    font.pixelSize: 12
                    leftPadding: 30
                    wrapMode: Text.WordWrap
                }
            }

            CheckBox {
                Layout.fillWidth: true
                text: "Keep the controller's native sample rate. Do not force a different rate; common controller rates are 44.1 kHz or 48 kHz."
                contentItem: Text {
                    text: parent.text
                    color: root.textColor
                    font.family: "Open Sans"
                    font.pixelSize: 12
                    leftPadding: 30
                    wrapMode: Text.WordWrap
                }
            }

            CheckBox {
                Layout.fillWidth: true
                text: "In the routing graph, connect the required source and destination nodes by clicking their circular connectors. Make sure the desired playback path is visibly connected."
                contentItem: Text {
                    text: parent.text
                    color: root.textColor
                    font.family: "Open Sans"
                    font.pixelSize: 12
                    leftPadding: 30
                    wrapMode: Text.WordWrap
                }
            }

            Text {
                Layout.fillWidth: true
                color: root.accentColor
                font.family: "Open Sans"
                font.pixelSize: 14
                font.weight: Font.DemiBold
                text: "5  FINAL CHECK"
            }

            CheckBox {
                Layout.fillWidth: true
                text: "Return to the main screen and load a track."
                contentItem: Text {
                    text: parent.text
                    color: root.textColor
                    font.family: "Open Sans"
                    font.pixelSize: 12
                    leftPadding: 30
                }
            }

            CheckBox {
                Layout.fillWidth: true
                text: "Move a controller control (for example a fader or jog/control input) and confirm NRave responds."
                contentItem: Text {
                    text: parent.text
                    color: root.textColor
                    font.family: "Open Sans"
                    font.pixelSize: 12
                    leftPadding: 30
                    wrapMode: Text.WordWrap
                }
            }

            CheckBox {
                Layout.fillWidth: true
                text: "Start playback and confirm that the expected audio output is active."
                contentItem: Text {
                    text: parent.text
                    color: root.textColor
                    font.family: "Open Sans"
                    font.pixelSize: 12
                    leftPadding: 30
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: supportText.implicitHeight + 20
                color: "#171D24"
                radius: 6
                border.color: root.accentColor
                border.width: 1

                Text {
                    id: supportText
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 10
                    color: root.textColor
                    font.family: "Open Sans"
                    font.pixelSize: 12
                    lineHeight: 1.25
                    text: "Still no sound or controller response? Start again at Step 3. Most USB problems are caused by the controller being connected in the wrong mode, the mapping not being enabled/saved, or the Sound Hardware routing not being restored after reconnecting the device."
                    wrapMode: Text.WordWrap
                }
            }
        }
    }
}
