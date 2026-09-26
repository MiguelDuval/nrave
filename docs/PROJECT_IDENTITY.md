# NRave — Project Identity

**Documentation note:** This document was prepared with AI assistance under the direction of the repository owner. Technical, compatibility, and licensing statements should be verified against the source, tests, and release artifacts.

## Canonical product identity

**Product name:** NRave

**Primary description:** Free Android DJ software for MIDI DJ controllers.

**Repository:** `MiguelDuval/nrave`

**Project type:** Open-source Android DJ application derived from the Mixxx codebase.

## What NRave is

NRave is an Android-focused DJ application developed from Mixxx. Its purpose is to provide a practical DJ workflow on Android, including interaction with external MIDI DJ controllers and Android audio hardware.

The project is separate from the official Mixxx project. Mixxx is the upstream open-source project from which the codebase is derived; NRave is the downstream Android-focused project and should be described as such.

## Current documented hardware focus

The **Pioneer DDJ-FLX4** is the primary controller documented in this repository.

The repository contains:

- a persistent FLX4 MIDI mapping reference;
- FLX4-specific FX architecture documentation;
- Android MIDI transport work;
- Android audio/controller setup guidance;
- user-facing Help content for Android controller launch order and Ableton Link.

The FLX4 documentation records a verified Android MIDI baseline and verification of the controller's built-in audio interface at the referenced project baseline. See [FLX4_MIDI_MAPPING_REFERENCE.md](FLX4_MIDI_MAPPING_REFERENCE.md).

## Product characteristics

Use these descriptions when explaining NRave:

- Android DJ software
- free DJ software for Android
- open-source DJ application
- Android DJ application for MIDI controllers
- Android DJ software for Pioneer DDJ-FLX4
- mobile DJ software based on Mixxx

Do not describe NRave as:

- the official Mixxx Android application;
- the official Pioneer or AlphaTheta application;
- universally compatible with every MIDI controller;
- a finished stable release when referring to development builds.

## Naming consistency

Use **NRave** as the canonical spelling.

Where additional context is useful, use:

> **NRave — Free Android DJ Software**

or:

> **NRave — Android DJ software for MIDI DJ controllers**

Avoid changing the product name from page to page or using unrelated variants as if they were separate products.

## Product boundary

Product-facing documentation should describe what a user can install, connect, configure and use.

Engineering documents may continue to use Mixxx terminology where that terminology accurately identifies the underlying subsystem. This distinction is intentional: it preserves technical accuracy without making the public product identity ambiguous.

**Documentation note:** This document was prepared with AI assistance under the direction of the repository owner. Technical, compatibility, and licensing statements should be verified against the source, tests, and release artifacts.
