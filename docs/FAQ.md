# NRave FAQ

**Documentation note:** This document was prepared with AI assistance under the direction of the repository owner. Technical, compatibility, and licensing statements should be verified against the source, tests, and release artifacts.

## What is NRave?

NRave is free, open-source DJ software for Android. It is developed from the Mixxx codebase with a focus on Android and external MIDI DJ controller workflows.

## Is NRave the official Android version of Mixxx?

No. NRave is a separate downstream project based on Mixxx source code.

## Is NRave free?

The project is intended to be distributed as free software. The repository's applicable licenses and notices are authoritative; see [LICENSE](../LICENSE).

## Can I use NRave with a DJ controller?

NRave is designed to work with MIDI DJ controllers through controller mappings. The amount of functionality available depends on the controller, mapping and Android hardware.

The Pioneer DDJ-FLX4 is the primary controller documented in the current repository.

## Can I use a Pioneer DDJ-FLX4 with Android?

The repository contains dedicated DDJ-FLX4 Android MIDI and mapping work, including a documented Android MIDI baseline and verification of the controller's built-in audio interface at that baseline.

Actual compatibility depends on the NRave build and the Android device/USB setup.

## Do I have to connect my controller before starting NRave?

For the current controller workflow, yes: connect the USB MIDI controller first, then launch NRave. The current in-app Help page specifically documents this order.

## Does NRave work with every Android phone?

No universal compatibility claim is made. Android hardware, USB behavior, audio routing and manufacturer power-management policies can affect DJ applications.

## Does NRave require internet access?

Core DJ operation is not documented as requiring an internet connection. Online services, downloads, updates and some integrations are separate concerns.

## What is Ableton Link used for?

NRave includes an Android Ableton Link integration. The current user-facing help describes Link synchronization between NRave and other Link-enabled devices on the same network.

## Where is the source code?

The complete project source is in this GitHub repository.

## Where do I get an Android build?

Use the repository's [Releases](../../releases) page for published builds.

**Documentation note:** This document was prepared with AI assistance under the direction of the repository owner. Technical, compatibility, and licensing statements should be verified against the source, tests, and release artifacts.
