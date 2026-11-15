# Research and probe log

Living document. Facts carry a date and a source. Probe results carry PASS/FAIL and log excerpts.

## 1. Why a Fcitx5 add-on (2026-11-12)
- **IBus:** ibus-daemon runs on the host and finds engines through `/usr/share/ibus/component/*.xml`.
  A Flatpak can't install files on the host, and there is no IBus Flatpak or extension point.
  This rules out an IBus engine.
- **Fcitx5:** Flathub's `org.fcitx.Fcitx5` is an app with an extension point:
  ```
  [Extension org.fcitx.Fcitx5.Addon]
  directory=addons  subdirectories=true  add-ld-path=lib  autodelete=true  no-autodownload=true  version=stable
  ```
  (from `flatpak info -m org.fcitx.Fcitx5` on this host, v5.1.23, runtime `org.kde.Platform/x86_64/6.11`).
- The launcher `/app/bin/fcitx5` (wrapper around `fcitx5-bin`), for each `/app/addons/<dir>`:
  - prepends `/app/addons/<dir>/lib/fcitx5` to `FCITX_ADDON_DIRS`
  - prepends `/app/addons/<dir>/share` to `XDG_DATA_DIRS`
  - prepends `/app/addons/<dir>/bin` to `PATH`
  - sets `LIBIME_MODEL_DIRS` when `/app/addons/<dir>/lib/libime` exists
- Add-ons already on Flathub: Chewing, ChineseAddons, Hangul, M17N, McBopomofo, McFoxIM, Mozc, Rime, Unikey, Zhuyin.
  M17N covers Bengali Probhat/Inscript, but not Avro phonetic, which is OBK's main value.
- Fcitx5 Flatpak `finish-args` include the session bus, Wayland, `inherit-wayland-socket`, x11,
  network, `xdg-config/fcitx:create` and `xdg-config/ibus` + `xdg-cache/ibus` (for the ibus frontend on GNOME).

## 2. Upstream: OpenBangla-Keyboard (2026-11-12)
- Repo: https://github.com/OpenBangla/OpenBangla-Keyboard. Maintainer: mominul.
- Release 2.0.0 (2020-10-01) is IBus only.
- `develop` @ `eea66aff18ac14cc43fa1273afd68729be5b5e67` (2026-10-17, "Merge #475 new-design") has `version.txt` = 3.0.0 (unreleased), with:
  - the fcitx5 engine (`src/engine/fcitx/`)
  - corrosion-based riti build (#465)
  - PlatformConfig
  - Khipro layout
  - GUI redesign
- Submodules: `src/engine/riti` @ `afee54a79e230165d38f6b17161cd8ff971e1c49`, `cmake/corrosion-rs` @ `f88df62d022d5a3a51118b0c8871f5d6b38a4771` (corrosion 0.6.1, needs CMake ≥ 3.22).
- CMake options: `ENABLE_IBUS`, `ENABLE_FCITX`, `ENABLE_BOTH` (one is required), and `BIN_DIR`, `DATADIR`, `LIBEXECDIR`, which default from `CMAKE_INSTALL_PREFIX`.
- `find_package(Qt5 COMPONENTS Widgets Network Svg REQUIRED)` is unconditional, and `src/frontend` (the GUI) is always built.
  The fcitx engine links only `Fcitx5::Core riti Pthread DL`.
- Rust:
  - riti (MPL-2.0, `rust-version = 1.75.0`) has **no Cargo.lock** (riti#362; nixpkgs vendors its own).
  - `src/platform` (the `system-theme` crate, which pulls in zbus/tokio) has a Cargo.lock.
- The fcitx build installs:
  - `lib/fcitx5/openbangla.so`
  - `share/fcitx5/{addon,inputmethod}/openbangla.conf` (Icon=openbangla-keyboard, Label=বা)
  - `share/openbangla-keyboard/{layouts,data,icons}`
  - hicolor icons, a desktop file, the metainfo `io.github.openbangla.keyboard.metainfo.xml`
  - `bin/openbangla-gui`
- Compile-time absolute paths:
  - `PROJECT_DATADIR "/data"` (riti database)
  - `BIN_DIR "/openbangla-gui"` (fcitx ExternalOption)
  - Both work if the prefix is `/app/addons/OpenBangla`.
- Config:
  - The GUI writes `QSettings("OpenBangla","Keyboard")` (`$XDG_CONFIG_HOME/OpenBangla/Keyboard.conf`), and the engine reads it through fcitx `StandardPath`.
  - User data goes to `$XDG_DATA_HOME/openbangla-keyboard`.
- `--setup-system` / `PlatformConfig.cpp` shell out to `dconf`, `gnome-extensions` and `kwriteconfig6`, and edit `~/.config/fcitx5/profile`. These won't work in the sandbox and aren't needed.
- Licenses: OBK GPL-3.0(+), riti MPL-2.0.
- Maintainer stance:
  - 2021: IMEs don't suit Flatpak (#267, #237).
  - 2026-11 (#485): prefers a pure-Rust GUI (GPUI or iced) over a Qt6 port.
  - #481 (2026-10-22): next release "next month".
  - wengxt (fcitx) on flathub/org.fcitx.Fcitx5#40 (2025-01): upstream should own the Flathub add-on.
- Prior art: https://github.com/tazihad/flatpaks/tree/main/org.fcitx.Fcitx5.Addon.OpenBangla
  (unofficial, from #390). It builds with KDE 5.15 SDK and copies Qt5 out of the SDK, needs a host-side
  icon script, has no license, and isn't on Flathub. Reference only; don't copy from it.
- Other packaging:
  - AUR `openbangla-keyboard-git` (split ibus/fcitx5, `-DBIN_DIR=/usr/bin`)
  - nixpkgs `openbangla-keyboard` + `fcitx5-openbangla-keyboard` (vendored riti Cargo.lock)
  - COPR `badshah/openbangla-keyboard`

## 3. Flathub conventions for Fcitx5 add-ons (2026-11-12)
From the human-written manifests at github.com/flathub/org.fcitx.Fcitx5.Addon.{Unikey,Hangul,Rime,M17N,McBopomofo,Chewing}:
- `runtime: org.fcitx.Fcitx5`, `runtime-version: stable`, `sdk: org.kde.Sdk//6.11`,
  `build-extension: true`, `separate-locales: false`, `build-options.prefix: /app/addons/<Name>`.
- They clean up `/include`, `/lib/pkgconfig`, `*.la`, and usually `/bin`.
- `flathub.json` = `{"skip-icons-check": true}`, because extensions can't export icons.
- The metainfo is installed by upstream, with `<component type="addon">`, `<extends>org.fcitx.Fcitx5</extends>` and `<project_group>Fcitx</project_group>`.
- Rust + corrosion reference: **Chewing** (rust-stable sdk-extension, `append-path`, corrosion built as its own module, per-module `CARGO_HOME`, cargo-sources JSON next to the manifest).
- Icons: the Fcitx5 app's `fcitx5-all-icons` module installs add-on icons inside the app, because extensions can't export them.
- Submission:
  - fork flathub/flathub, branch `new-pr`, PR "Add <id>", then `bot, build`
  - extension IDs must be prefixed with the extension point ID and are exempt from domain verification
  - McBopomofo and McFoxIM were submitted by their own upstreams and merged by Flathub reviewers
- Linter: `flatpak run --command=flatpak-builder-lint org.flatpak.Builder manifest|repo …`.
- **Generative AI policy** (flathub-infra/documentation `docs/02-for-app-authors/02-requirements.md`, restored 2026-09-21):
  > Flathub manifests must not contain AI-generated or AI-assisted content. Disclosure does not exempt manifests from this restriction.
  > AI tools or agents must not open or automate Flathub submission pull requests, or generate their commit messages, descriptions, review comments, or replies.

  Other AI-generated material in the app or packaging must be disclosed. AI used only for research, discussion or debugging needs no disclosure.

## 4. Dev environment (2026-11-12)
- Host: Bazzite 45 (Kinoite), KDE Plasma Wayland. KWin `InputMethod` is the Fcitx5 Flatpak desktop file.
  Fcitx5 config is in `~/.var/app/org.fcitx.Fcitx5/config/fcitx5`.
- Container `dev` (distrobox, Fedora 45 toolbox image):
  - runs with `--privileged`, `label=disable` and `unmask=all`
  - `bwrap --unshare-all` works and `/dev/fuse` is present
  - sees the host's system Flatpak installation via `FLATPAK_SYSTEM_DIR=/run/host/var/lib/flatpak` (after `dnf install flatpak-builder` brings in the real flatpak package, which otherwise sees only the container's empty system dir)
  - `flatpak-spawn` and `distrobox-host-exec` are available
- Tooling pinned: flatpak-builder-tools `cargo/flatpak-cargo-generator.py` @ `9d86d336a39b9af38b86f114b6ce5820fe260f91`.

## 5. Probe log
_Phase 1 results go here (step, date, PASS/FAIL, evidence)._

**Code reading (2026-11-12), `src/engine/fcitx/openbangla.cpp`:**
- `populateConfig()` defaults `layoutPath = "avro_phonetic"` when no `layout/path` key exists.
  With no `OpenBangla/Keyboard.conf`, the engine should type Avro Phonetic (verified in 1.4).
- The config is read through `StandardPath::Type::Config` → `OpenBangla/Keyboard.conf`.
  Inside the Fcitx5 sandbox that is `~/.var/app/org.fcitx.Fcitx5/config/OpenBangla/Keyboard.conf`,
  so power users can hand-edit the INI keys (`layout/path`, `settings/...`) without the GUI.
- The fcitx engine links only `Fcitx5::Core riti Pthread DL`. `src/shared` (Qt5::Core) is used by the
  IBus engine and the GUI, and `src/platform` (second Rust crate) only by the GUI.
- Probe patch (branch `probe/engine-only` in `upstream/`, exported to `docs/probes/0001-engine-only-ENABLE_GUI.patch`) adds `option(ENABLE_GUI ON)`, which gates
  `find_package(Qt5)`, `src/platform`, `src/frontend` and `src/shared`. This is the draft for upstream PR-a.

| Probe | Result | Evidence |
| --- | --- | --- |
| 1.1 build shell (KDE 6.11 SDK + fcitx headers + cargo) | **PASS** (2026-11-12) | `scripts/probe-build.sh`: `flatpak run --devel org.fcitx.Fcitx5` with the user rust-stable//25.08 extension on PATH. cmake 4.4.4, GCC 15.2.0, rustc/cargo 1.98.1. `find_package(Fcitx5Core)` resolves from `/app`. |
| 1.2 engine-only build | **PASS** (2026-11-12) | `probe-build.sh engine` (`-DENABLE_FCITX=ON -DENABLE_GUI=OFF`, patch `docs/probes/0001`): builds in ~25 s and installs `lib/fcitx5/openbangla.so`, the addon/inputmethod confs, 7 layouts, 4 data JSONs, icons, a desktop file and the metainfo. The only warnings are 6× deprecated `StandardPath` (fcitx 5.1.23); this is a future-compat risk worth an upstream port to `StandardPaths`. **Gotcha:** without `-DCMAKE_INSTALL_LIBDIR=lib` the .so lands in `lib64/`, which the Fcitx5 launcher does not search. flatpak-builder passes `lib` for cmake modules by default. |
| 1.3 offline cargo sources | **PASS** (2026-11-12) | `scripts/gen-cargo-sources.sh`: riti lock generated (45 pkgs; okkhor 0.8.2, once_cell 1.20.3 pinned by semver), 91 source entries; platform 209 entries. `cargo fetch --locked` then `cargo build --release --locked --offline` of riti → `libriti.a` (cargo 1.99.1). Only riti is needed for the engine-only build, because `src/platform` is linked only by the GUI. |
| 1.4 runtime typing test | **PASS (headless)**; in-app pending user | `probe-install.sh engine` (manifest-free `build-export` of the staged files, installed `--user` from local remote `obk-probe`). The host Fcitx5 mounts `/app/addons/OpenBangla`, `ldd` is clean, and Controller1 lists addon `openbangla` and IM `openbangla` ("OpenBangla Keyboard", icon `openbangla-keyboard`). `scripts/probe-type.py` (D-Bus input-context frontend): `ami banglay gan gai` → `আমি বাংলায় গান গাই` **PASS** with no config (default Avro Phonetic); `amar sonar bangla, ami tomay valobasi.` → `আমার সোনার বাংলা, আমি তমায় ভালবাসি।`. A hand-written `~/.var/app/org.fcitx.Fcitx5/config/OpenBangla/Keyboard.conf` with `[layout] path=/app/addons/OpenBangla/share/openbangla-keyboard/layouts/Probhat.json` + `ReloadAddonConfig` → `kj` = `কজ` (fixed layout works without the GUI). User data dir: `~/.var/app/org.fcitx.Fcitx5/data/openbangla-keyboard`. The engine emits precomposed U+09DF য়, so compare under NFC. **Still to do (user):** typing in real apps (Kate Flatpak, native Qt/GTK, XWayland) and the tray icon. |
| 1.5 Qt6 GUI port sizing | **PASS** (2026-11-12) | Branch `probe/qt6` (`docs/probes/0002`): **7 files, +14/−11**. Changes: `find_package(QT NAMES Qt6 Qt5)` + `Qt${QT_VERSION_MAJOR}::` targets; `QStringRef`→`auto` and `contains(QLatin1String(..))` in LayoutConverter; `#include <QActionGroup>` in TopBar; `QJsonValue::toVariant()` in AutoCorrectDialog. Also fixes an upstream bug exposed by Qt6: `configure_file("${CMAKE_MODULE_PATH}/cmake_uninstall.cmake.in")` breaks once `CMAKE_MODULE_PATH` is a list, so it now uses `${CMAKE_SOURCE_DIR}/cmake`. Builds against Qt 6.11.3 with only deprecation warnings (QMouseEvent x/y, StandardPath). `openbangla-gui` runs in the Fcitx5 sandbox (offscreen, alive at 8 s) and writes `~/.var/app/org.fcitx.Fcitx5/config/OpenBangla/Keyboard.conf`, the same file the engine reads. It is not on the sandbox PATH (only the fcitx5 wrapper adds addon `bin/`), but fcitx's ExternalOption uses the absolute `BIN_DIR`. `--setup-system`/PlatformConfig only runs on that explicit flag. |

## 6. Reliability / pressure testing (2026-11-12)
User report (KDE Wayland, probe add-on installed): typing Bangla works, but it is "unreliable, suddenly will
switch to english", and there is no tray icon. (The user also removed openbangla from the IM list mid-test,
which explains the spurious losses in the runs against the live daemon.)

**Tooling:** `scripts/stress-ime.py` (D-Bus input-context frontend; scenarios shift-tap, new-ic, refocus, soak, burst;
tracks the test context's own IM via its `CurrentIM` signal) and `scripts/stress-isolated.sh` (private
`dbus-run-session`, private XDG dirs set **inside** the sandbox, only addons dbus,dbusfrontend,keyboard,openbangla).

| Scenario | Fcitx5 default config | Hardened (`[Hotkey/AltTriggerKeys]` empty, `ShareInputState=All`) |
| --- | --- | --- |
| shift-tap (Left Shift alone, 30/100/200/400 ms) | **FAIL**: 30–200 ms taps switch to keyboard-us; 400 ms does not (modifier-only timeout) | PASS |
| new-ic (second context = new window/app) | **FAIL**: new context starts in keyboard-us | PASS |
| refocus ×500 | PASS | PASS |
| soak: 20k random keys (letters, Shift+caps, space, BS, arrows/Tab, punctuation, digits, Return, Ctrl+BS) | PASS: 0 losses, 0 D-Bus errors, worst 1.2 ms, RSS 21.6→21.9 MB | PASS (worst 3.7 ms) |
| burst: 4,800 keys / 800 words | PASS: 800/800 committed, 0.80 ms/key | PASS |

**First conclusion (superseded by the reviews below):** the engine is stable under load. The "switches to English" symptoms come from two
Fcitx5 *defaults* (Left-Shift AltTrigger; per-context input state), not from the add-on.

**Incidents during testing (fixed):**
- Flatpak overrides `XDG_CONFIG_HOME`/`XDG_DATA_HOME` even with `--env`, so the first "isolated" runs used the
  user's real Fcitx5 dirs. They re-saved an unchanged profile, left an empty `profile_XXXX` temp file, and,
  together with the earlier soak runs on the live daemon, filled `data/openbangla-keyboard/phonetic-candidate-selection.json`
  with 90 junk entries. Cleaned up (junk kept at `out/evidence/`, the user's data file removed, Fcitx5 restarted to drop
  in-memory state). The runner now exports the XDG dirs inside the sandbox and refuses to start otherwise; a before/after
  fingerprint of the user's Fcitx5 config and data dirs was identical across the fixed runs.
- Anomaly under review: some learned selections show duplicated output (`bei → 🅱️েই🅱️েই`, `vei → vেইvেই`).

### 6.1 Expert reviews (3 independent agents, 2026-11-12)
**Verdict:** the user's symptom is explained by Fcitx5 defaults. The engine is **not** stable: it has three verified
classes of crash that kill the whole Fcitx5 daemon (panics can't unwind across riti's `extern "C"` FFI) and two
verified silent text-loss bugs. The random soak never reached these paths. The host journal and coredumpctl
(30 days, read-only) show no crash of the live daemon; all 18 KWin "Input Method crashed" entries were SIGTERM restarts.

**Engine and riti bugs (all upstream; develop eea66aff, riti afee54a):**

| # | Severity | Where | Trigger, then effect | Verified |
| --- | --- | --- | --- | --- |
| 1 | crash, **persists on disk** | riti `phonetic/suggestion.rs:266` `.last().unwrap()`; value saved by `method.rs:116-125` with a key/value split mismatch | Type `:)` and pick the literal candidate; `{":":""}` is saved. Later typing `:e` (any suffix) aborts fcitx5, and it aborts again after every restart. | yes, independently reproduced (`panicked at src/phonetic/suggestion.rs:266:55`) |
| 2 | crash (SIGSEGV) | `openbangla.cpp:337-339`, `142-143` null candidate list; `context()` line 407 never assigns `currentIC_` (dead guard), so riti session state is global | Keys reach a second input context while the first is mid-word | yes (reviewers; isolated) |
| 3 | crash | riti `unwrap`s: corrupt or truncated `phonetic-candidate-selection.json` (`method.rs:32`), an unwritable file (`method.rs:126-130`, non-atomic `fs::write`), a missing `layout/path` file (`fixed/method.rs:109`), a torn `autocorrect.json` (`method.rs:143`) | Disk full, a crash mid-write, or a host Keyboard.conf with `/usr/share` paths: fcitx5 aborts on every activation | yes |
| 4 | text loss | `commit()` uses page-local `cursorIndex()` (-1 after paging) | `kotha`, NextPage, Space: nothing committed, the session stays open, and the next word merges (`কথার`) | yes, independently reproduced |
| 5 | data corruption | riti `suggestion.rs:258-293`: suffix loop has no `break` and writes derived values back into `selections` | Learned preferences stop applying to inflected words, and doubled strings get stored (`bei → 🅱️েই🅱️েই`) | yes |
| 6 | text loss | no `deactivate` override; `reset()` drops the preedit | Switching IM mid-word (Shift-tap, Ctrl+Space, SetCurrentIM) loses the word | yes |
| 7 | perf | `openbangla.cpp:492` uses `<`, so Keyboard.conf is re-read at every word start | Stat + INI parse + `update_engine` per word | yes |
| 8 | memory | unknown (leak or allocator) | RSS 21.5 → 40 MB over 350k keys, roughly linear; needs heaptrack | yes (growth only) |
| 9 | growth | selection file rewritten in full on every non-default pick, unbounded | 1230 entries / 30 KB after ~650k random keys | yes |

**Fcitx5 configuration (source-cited, verified in isolation):** the recommended user config is
```
[Hotkey]
AltTriggerKeys=

[Behavior]
ShareInputState=All
ActiveByDefault=True
```
- `ActiveByDefault` exists in 5.1.23 and makes new contexts start active.
- Ctrl+Space remains the toggle. Shift+letter typing is unaffected.
- An add-on **cannot** ship global defaults: the first `fcitx5/config` in XDG_CONFIG_HOME/XDG_CONFIG_DIRS wins, with no merging.
  The only data-dir hook is `share/fcitx5/default/<locale>` for a first-run profile. The recommendation is documentation; an
  opt-in setup helper via `Controller1.SetConfig("fcitx://config/global", …)` works (verified on a private bus).
- KWin input-method-v1 in fcitx5 uses one Wayland IC plus per-Plasma-window virtual ICs (`DetectApplication`), so
  "per-IC state" means per-window state. Field changes within a window keep state.

**Tray icon:** the SNI sends `IconName=openbangla-keyboard`, and the host theme lacks it because extensions can't export icons.
- Correct fix: upstream `Icon=fcitx-openbangla` plus an icon layout under `data/icons/<size>/apps/`, then a hand-written
  PR adding OBK to `fcitx5-all-icons` in flathub/org.fcitx.Fcitx5 (the Unikey/McBopomofo precedent).
- Interim options: Classic UI "Prefer Text Icon" (renders বা), or copying the PNG to `~/.local/share/icons/hicolor` on the host.

**Harness gaps to fix (from the methodology review):**
- capabilities 0 (Wayland uses 0x72), so preedit and focus-out paths go untested
- "stolen" focus never fails in isolation
- no content check in soak or burst
- the RSS threshold can't detect slope
- concurrent runs of the same profile clobber each other
- the `pgrep fcitx5-bin` fallback could match the live daemon
- isolated D-Bus ICs have no focus group (two contexts can be focused at once)
- a nested `kwin_wayland --virtual` run is the only faithful end-to-end test

Reviewer reproductions are in the session scratchpad (`repro/repro.c`, `e2e/e2e.py`, `extra.py`, `harness/`, `iso.sh`). Copy them
into `tests/` if adopted.

### 6.2 Memory (F8) diagnosis (2026-11-14)
| Scenario (isolated, 12 × 25k keys) | RSS KiB per chunk | Slope after warm-up |
| --- | --- | --- |
| `rss-slope`: random keys | 21856, 24996, 24996, 28132, 28288, 28932, 29540, 36432, 37028, 37620, 38248, 38844 | 1597 KiB/25k (FAIL) |
| `rss-vocab`: 2,000-word vocabulary | 21992, 20968, 20968, … 20968 | 0 KiB/25k (PASS) |

Cause: riti `PhoneticSuggestion.cache` (`src/phonetic/suggestion.rs:221-233`) caches dictionary results for every distinct word
(and prefix) and is never trimmed. Bounded in real use; unbounded for random input. This is not a leak. A possible upstream
improvement is an LRU bound.
