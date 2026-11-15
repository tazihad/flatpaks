# Maintenance procedure

Who does what follows the Flathub Generative AI policy (see `CLAUDE.md`). The
maintainer edits `flathub/` and all Flathub PRs and commits. Claude runs builds,
lints and tests, and explains failures.

## Upstream bump (new OBK commit or tag)
1. Update the workspace clone:
   `git -C upstream/OpenBangla-Keyboard fetch && git -C upstream/OpenBangla-Keyboard checkout <commit> && git -C upstream/OpenBangla-Keyboard submodule update --init`
2. **Maintainer:** `scripts/gen-cargo-sources.sh -o <dir>` and review the diff of the generated files.
   Remember to update riti's commit if the submodule moved.
3. **Maintainer:** edit the manifest in `flathub/` (source commits and tags, cargo sources).
4. `scripts/build.sh && scripts/lint.sh && scripts/test-run.sh`, then a manual typing check.
5. **Maintainer:** commit and push to the Flathub repo, or update the bot's PR (flatpak-external-data-checker
   opens bump PRs, but it can't regenerate cargo sources).

## Fcitx5 runtime changes
When `org.fcitx.Fcitx5` moves to a new KDE runtime (e.g. 6.11 → 6.12):
1. `scripts/devenv-setup.sh` after updating `USER_REFS` in it.
2. **Maintainer:** bump `sdk:` in the manifest, then rebuild, lint and test.

## Release checklist
- [ ] build, lint (manifest + repo) and test-run are all green
- [ ] typing test passes in a Flatpak app and a native app
- [ ] metainfo `<releases>` has the new version (upstream)
- [ ] `docs/research.md` probe or test log updated
