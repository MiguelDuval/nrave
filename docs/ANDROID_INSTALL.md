# Android Installation and First Launch

**Documentation note:** This document was prepared with AI assistance under the direction of the repository owner. Technical, compatibility, and licensing statements should be verified against the source, tests, and release artifacts.

## Before launching NRave

For the current controller workflow, **connect the USB MIDI controller to the Android device before starting NRave**.

The application help currently warns that a controller connected after the application has already started may not be detected correctly.

Recommended order:

1. Connect the controller and any required USB hardware.
2. Start NRave.
3. Grant the Android permissions required by your setup.
4. Open a library track and verify playback.
5. Move a controller control and verify that NRave responds.
6. Confirm the audio output you intend to use.

## Permissions

Android may ask for access to music/files, microphone input, or USB hardware depending on the features and hardware used.

Grant only the permissions required for the setup you are using.

## Reliable DJ use

For live use, Android power management can interrupt audio or USB communication on some devices.

Where the device provides these settings, consider:

- allowing NRave to run in the background;
- disabling aggressive battery optimization for NRave;
- avoiding unnecessary background applications during a performance.

These are Android-device recommendations, not guarantees of identical behavior across all manufacturers.

## Controller troubleshooting

If NRave does not react to a connected MIDI controller:

- confirm that the controller was connected before launching NRave;
- check the Android USB/MIDI permission prompt;
- confirm that the controller appears in NRave's Controller settings;
- restart NRave with the controller already connected;
- verify the controller-specific mapping documentation before changing mappings.

For the Pioneer DDJ-FLX4, start with [COMPATIBILITY.md](COMPATIBILITY.md) and [FLX4_MIDI_MAPPING_REFERENCE.md](FLX4_MIDI_MAPPING_REFERENCE.md).

**Documentation note:** This document was prepared with AI assistance under the direction of the repository owner. Technical, compatibility, and licensing statements should be verified against the source, tests, and release artifacts.
