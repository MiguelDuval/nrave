# NRave — Free Android DJ Software

**Documentation note:** This product-facing documentation was prepared with AI assistance under the direction of the repository owner. Technical, compatibility, and licensing statements should be verified against the source, tests, and release artifacts.

NRave is a free, open-source **DJ application for Android** focused on using Android devices with MIDI DJ controllers and a mobile-oriented DJ workflow.

This repository contains the NRave application source, together with the upstream Mixxx codebase on which NRave is based. NRave is an independent downstream project and is **not the official Mixxx project**.

## What is NRave?

NRave brings a DJ workflow based on Mixxx to Android.

The project is intended for people who want to use an Android device as part of a DJ setup rather than being limited to a traditional desktop or laptop workflow.

Current project documentation includes dedicated work for:

- Android DJ operation and mobile UI
- USB MIDI controller workflows
- Pioneer DDJ-FLX4 mapping and integration
- Android audio and controller setup
- Ableton Link synchronization
- DJ effects and controller interaction
- installation, troubleshooting, and user help

The **Pioneer DDJ-FLX4** is the current primary documented controller target. The repository contains a detailed FLX4 MIDI reference and records an Android MIDI baseline in which FLX4 MIDI input and the controller's built-in audio interface were verified.

## Start here

### Download

For released Android builds, see the repository's [Releases](../../releases) page.

### Documentation

- [Project identity and scope](docs/PROJECT_IDENTITY.md)
- [Android installation and first launch](docs/ANDROID_INSTALL.md)
- [Controller compatibility](docs/COMPATIBILITY.md)
- [Frequently asked questions](docs/FAQ.md)
- [Upstream Mixxx relationship and project scope](docs/UPSTREAM_AND_PROJECT_SCOPE.md)
- [DDJ-FLX4 MIDI mapping reference](docs/FLX4_MIDI_MAPPING_REFERENCE.md)
- [DDJ-FLX4 FX architecture](docs/FLX4_FX_ARCHITECTURE.md)
- [Ableton Link on Android](docs/ABLETON_LINK_ANDROID_IMPLEMENTATION.md)

## Canonical identity

The public product name is **NRave**.

The clearest description of the product is:

> **NRave is free Android DJ software for MIDI DJ controllers.**

For public references, documentation and search-facing pages should prefer the consistent form **NRave — Android DJ software** rather than presenting the repository as a generic Mixxx mirror.

## Why the repository still contains Mixxx references

NRave is developed from the Mixxx source tree. Some technical documents, source files, controller mappings, build instructions and historical material therefore retain upstream terminology.

That information should not be interpreted as saying that NRave is an official Mixxx release. Product-facing information is maintained separately in this repository's NRave documentation.

The upstream license and copyright notices remain part of the repository and must be preserved. See [LICENSE](LICENSE) for the applicable license text and notices.

## Project principles

NRave is being developed around a few simple principles:

- **Android first:** the user experience is designed for Android rather than treating a phone as a small desktop screen.
- **Real hardware:** controller behavior is based on actual MIDI hardware and tested workflows.
- **Clear documentation:** supported hardware, limitations, setup steps and implementation status should be stated explicitly.
- **Open development:** source, technical references and project history remain publicly inspectable.
- **No invented capabilities:** documentation should describe verified or clearly documented behavior, not marketing claims that the software cannot substantiate.

## Contributing and development

The repository retains upstream Mixxx development conventions and build documentation where those remain relevant. See [CONTRIBUTING.md](CONTRIBUTING.md) and [AGENTS.md](AGENTS.md) for the inherited development rules.

NRave-specific product and user documentation lives in [docs/](docs/).

## Links

- [NRave source repository](https://github.com/MiguelDuval/nrave)
- [NRave releases](../../releases)
- [Mixxx](https://mixxx.org/)
- [Mixxx source repository](https://github.com/mixxxdj/mixxx)

**Documentation note:** This product-facing documentation was prepared with AI assistance under the direction of the repository owner. Technical, compatibility, and licensing statements should be verified against the source, tests, and release artifacts.
