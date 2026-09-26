# NRave Controller Compatibility

**Documentation note:** This document was prepared with AI assistance under the direction of the repository owner. Technical, compatibility, and licensing statements should be verified against the source, tests, and release artifacts.

## Pioneer DDJ-FLX4

The Pioneer DDJ-FLX4 is the primary controller covered by the current NRave documentation.

The repository records an Android MIDI baseline in which:

- DDJ-FLX4 MIDI input was verified on Android;
- the controller's built-in audio interface was verified by the project owner at the referenced baseline.

The exact hardware behavior depends on the current NRave build, Android device, USB connection and mapping state.

For implementation details, see [FLX4_MIDI_MAPPING_REFERENCE.md](FLX4_MIDI_MAPPING_REFERENCE.md).

## What compatibility means here

A controller can communicate over MIDI without every control having a complete NRave mapping.

Compatibility may involve several separate layers:

1. USB connection and Android MIDI transport.
2. MIDI input recognition.
3. Controller mapping.
4. Audio input/output.
5. Application features exposed by the mapping.

Therefore, “MIDI controller support” should not be interpreted as “every control on every controller is supported.”

## Other MIDI controllers

NRave is built on an architecture capable of working with MIDI controllers through mappings, but this repository does not claim universal support.

Use the controller's documented MIDI messages and an NRave/Mixxx mapping appropriate to the hardware before assuming that a specific control or feature is available.

## Reporting a compatibility issue

A useful compatibility report should include:

- controller model;
- Android device/model;
- Android version;
- connection method/USB adapter;
- NRave build or release;
- whether the controller is visible to Android;
- whether MIDI input is received;
- whether audio I/O works;
- the specific controls or features that fail.

This information separates transport, mapping and audio problems and makes regressions easier to diagnose.

**Documentation note:** This document was prepared with AI assistance under the direction of the repository owner. Technical, compatibility, and licensing statements should be verified against the source, tests, and release artifacts.
