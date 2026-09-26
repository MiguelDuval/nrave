# NRave and the Upstream Mixxx Project

**Documentation note:** This document was prepared with AI assistance under the direction of the repository owner. Technical, compatibility, and licensing statements should be verified against the source, tests, and release artifacts.

## Relationship to Mixxx

NRave is an independent downstream project developed from the Mixxx source code.

This distinction matters:

- **Mixxx** is the upstream open-source DJ software project.
- **NRave** is the Android-focused project maintained in this repository.
- NRave may retain Mixxx architecture, source files, controller mappings and technical terminology because those components form the foundation of the application.

NRave should therefore be described as **based on Mixxx**, not as an official Mixxx product.

## Why upstream terminology remains

The repository is a large source tree derived from Mixxx. Removing every upstream reference would be risky and would make development and provenance less clear.

The project instead uses two documentation layers:

1. **Product-facing NRave documentation** — explains NRave to users and search engines in clear product language.
2. **Engineering/upstream documentation** — preserves the technical terminology needed to maintain the inherited Mixxx architecture correctly.

This separation allows the public identity to be NRave without rewriting or obscuring the underlying technical provenance.

## Licensing and attribution

The repository's existing license and copyright notices are retained.

Do not replace the upstream [LICENSE](../LICENSE) with a simplified product license or remove upstream notices as part of documentation work.

For licensing questions, the actual license files in the repository are authoritative.

## Documentation rule

When a user asks what the product is, start with **NRave** and its Android DJ purpose.

When a developer asks how an inherited subsystem works, it is appropriate to use the established Mixxx subsystem name.

This is not a contradiction. It is a deliberate distinction between product identity and implementation provenance.

**Documentation note:** This document was prepared with AI assistance under the direction of the repository owner. Technical, compatibility, and licensing statements should be verified against the source, tests, and release artifacts.
