# Upstream brief: facts and asks for the OpenBangla maintainers

Source material for the issue **you** write and post on OpenBangla/OpenBangla-Keyboard
(plan step 2.1). These are notes, not text to paste: write the issue in your own words.
Evidence for every item is in `docs/research.md` §5.

## Context worth stating
- Immutable distros (Silverblue, Kinoite, Bazzite, Aurora, Bluefin, Aeon) can't easily install
  IBus or Fcitx engines. Flathub's `org.fcitx.Fcitx5` supports add-on extensions
  (`org.fcitx.Fcitx5.Addon.*`; 10 exist, e.g. Unikey, Hangul, McBopomofo).
- IBus engines can't be shipped through Flatpak, so this only covers the Fcitx5 path.
- wengxt (fcitx maintainer) said in flathub/org.fcitx.Fcitx5#40 that upstream should own such add-ons.
- You've built and tested it: `develop` @ `eea66aff` builds against the Flathub Fcitx5
  runtime (KDE SDK 6.11, Fcitx 5.1.23), loads in the Flatpak Fcitx5, and types Avro Phonetic
  correctly (`ami banglay gan gai` → `আমি বাংলায় গান গাই`).

## Asks (each one small; offer to send PRs)
1. **Build switch for an engine-only build** (`ENABLE_GUI`, default ON). Today Qt5 is
   `REQUIRED` even though the fcitx engine links only `Fcitx5::Core` and riti.
   Prototype: `docs/probes/0001-engine-only-ENABLE_GUI.patch` (1 file).
2. **Qt6 support for the GUI** (Qt5 fallback kept). The Flatpak Fcitx5 runs on Qt 6.11 and has no Qt5.
   Prototype: `docs/probes/0002-qt6-port.diff`, 7 files, +14/−11. The GUI runs inside the sandbox
   and writes the same `Keyboard.conf` the engine reads.
   - Acknowledge #485 (the maintainer prefers a future Rust GUI). Ask whether a small Qt6
     compatibility change is acceptable in the meantime.
   - The same diff fixes a latent bug: `configure_file("${CMAKE_MODULE_PATH}/cmake_uninstall.cmake.in")`
     breaks once `CMAKE_MODULE_PATH` is a list (Qt6 makes it one).
3. **Commit a `Cargo.lock` in riti** (riti#362). Flatpak builds are offline and need a lockfile.
   Today the packager has to generate one (nixpkgs does the same).
4. **Add-on metainfo upstream:** `org.fcitx.Fcitx5.Addon.OpenBangla.metainfo.xml` with
   `type="addon"`, `<extends>org.fcitx.Fcitx5</extends>`, releases and content rating.
   This follows the pattern of fcitx5-unikey's `org.fcitx.Fcitx5.Addon.Unikey.metainfo.xml.in`.
   Flathub prefers metadata to live upstream.
5. **Tag 3.0.0.** fcitx support exists only on `develop`; Flathub prefers tagged releases.
6. **Who maintains the Flathub add-on:** offer to maintain it, or to co-maintain with upstream
   as owner. Ask which the maintainer prefers.

## Optional, lower priority
- Port the six deprecated `fcitx::StandardPath` uses in `src/engine/fcitx/openbangla.cpp` to
  `StandardPaths` before fcitx removes the old API.
- Icons: extensions can't export icons to the host. Ask whether upstream minds the Flathub
  Fcitx5 app bundling OBK's `openbangla-keyboard` icon (in its `fcitx5-all-icons` module),
  so the tray and kimpanel icon resolves.

## Disclosure
Say that the prototype patches were AI-assisted (Claude), and that you'll review and own any PR you open.
