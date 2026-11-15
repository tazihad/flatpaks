# Using OpenBangla Keyboard from Flatpak (draft)

> Draft. Each section is validated in Phase 4 of the plan before it's published.

OpenBangla Keyboard ships as an add-on for the **Fcitx5** input method Flatpak.
It works the same way on immutable distros (Fedora Silverblue and Kinoite, Bazzite, Aurora, Bluefin, openSUSE Aeon, …) and on regular ones.

## 1. Install
```sh
flatpak install flathub org.fcitx.Fcitx5 org.fcitx.Fcitx5.Addon.OpenBangla
```

## 2. Enable Fcitx5

### KDE Plasma (Wayland)
1. Open **System Settings → Keyboard → Virtual Keyboard** and select **Fcitx 5**, then apply.
2. Don't set `GTK_IM_MODULE` or `QT_IM_MODULE`. For older X11 (XWayland) apps, setting
   `XMODIFIERS=@im=fcitx` (e.g. in `~/.config/environment.d/fcitx.conf`) helps.
3. Don't use "Restart" from the Fcitx5 tray menu on Wayland. Log out and back in instead.

### GNOME (Wayland)
_To be validated._ GNOME talks to input methods over the IBus protocol, so Fcitx5 has to replace ibus-daemon:
1. Autostart Fcitx5 (`flatpak run org.fcitx.Fcitx5` in Startup Applications, or a
   `~/.config/autostart` entry).
2. Install the **Kimpanel** GNOME extension so the candidate window draws properly.

## 3. Add OpenBangla
Open **Fcitx5 Configuration** (`flatpak run --command=fcitx5-config-qt org.fcitx.Fcitx5`),
uncheck "Only Show Current Language", and add **OpenBangla Keyboard** to the input methods.
Switch with `Ctrl+Space` (the default trigger).

Test: type `ami banglay gan gai` and you should get `আমি বাংলায় গান গাই`.

## 4. Known limitations (v1)
- No settings window yet. The default layout is Avro Phonetic. _(Confirm in Phase 1.)_
- The tray icon may show a generic icon. _(Tracked upstream and in the Fcitx5 Flatpak.)_
- Host (non-Flatpak) GTK or Qt apps on X11 may need the distro's `fcitx5-gtk`/`fcitx5-qt` packages.
