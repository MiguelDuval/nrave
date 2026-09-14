# NRave — Permanent AI/Agent Working Rules

## 1. Authoritative working repository

**The public repository `MiguelDuval/nrave` is the authoritative and active development repository for NRave.**

All normal NRave development must be performed in this public repository unless Sergey explicitly instructs otherwise.

This includes:
- feature development;
- bug fixes;
- Android/QML work;
- controller and engine work;
- refactoring;
- CI/workflow changes;
- development builds and test builds;
- verification commits and release-preparation work that is still part of active development.

## 2. Private repository is NOT the development workspace

`MiguelDuval/NRave-release-private-` is a **private preservation/release vault**.

It must NOT be used for ordinary development, feature work, experimental changes, or routine CI builds.

Do not create or modify files, branches, or commits in the private repository unless Sergey explicitly asks for a specific private-repository action.

## 3. Release snapshots

The private repository may contain preserved release candidates, stable checkpoints, emergency backups, or other material that Sergey explicitly asks to keep private.

A release snapshot may be copied into the private repository before or during a release process, but active development continues in the public repository.

## 4. Default rule for new chats

When beginning work on NRave in a new chat, **assume `MiguelDuval/nrave` is the target repository**.

Do not infer that work should be performed in `MiguelDuval/NRave-release-private-` merely because a release branch or release snapshot exists there.

If repository choice is ambiguous, prefer the public repository and verify its state before making changes.

## 5. GitHub Actions / CI

Use the public repository for routine GitHub Actions workflows and development builds. This avoids unnecessary consumption of the limited private-repository Actions allowance.

Do not move ordinary build/test activity to the private repository.

## 6. Secrets and confidential material

Public development does **not** mean secrets belong in the public repository.

Never commit:
- signing keystores or private keys;
- passwords;
- API keys or access tokens;
- GitHub Actions secrets;
- other confidential credentials.

These must remain in GitHub Secrets or another appropriate secret store.

## 7. Safety before destructive operations

Before deleting, rewriting, force-moving, or otherwise destructively changing a public branch, verify that any required checkpoint has already been preserved in the private vault or another explicitly approved backup.

Do not delete the private preservation copy merely because a public branch was removed.

## 8. Explicit override

Sergey can override these rules by explicitly requesting a private-repository operation. Such an instruction applies only to the requested action and does not change the default rule that normal development belongs in `MiguelDuval/nrave`.
