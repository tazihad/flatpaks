#!/bin/sh
set -e

# Install OpenBangla Keyboard icons & desktop launcher to the host
# Flatpak addon runtimes cannot export icons to the host system tray automatically.
# Running this script registers the icons and desktop entry with KDE Plasma / GNOME.

USER_FLATPAK_ICONS="$HOME/.local/share/flatpak/runtime/org.fcitx.Fcitx5.Addon.OpenBangla/x86_64/stable/active/files/share/icons/hicolor"
SYSTEM_FLATPAK_ICONS="/var/lib/flatpak/runtime/org.fcitx.Fcitx5.Addon.OpenBangla/x86_64/stable/active/files/share/icons/hicolor"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR_ICONS="$SCRIPT_DIR/.flatpak-builder/build/fcitx5-openbangla-2/data"

echo "Locating OpenBangla icons..."

if [ -d "$USER_FLATPAK_ICONS" ]; then
    SRC_MODE="flatpak_tree"
    BASE_SRC="$USER_FLATPAK_ICONS"
elif [ -d "$SYSTEM_FLATPAK_ICONS" ]; then
    SRC_MODE="flatpak_tree"
    BASE_SRC="$SYSTEM_FLATPAK_ICONS"
elif [ -d "$BUILD_DIR_ICONS" ]; then
    SRC_MODE="raw_dir"
    BASE_SRC="$BUILD_DIR_ICONS"
elif [ -d "$SCRIPT_DIR/data" ]; then
    SRC_MODE="raw_dir"
    BASE_SRC="$SCRIPT_DIR/data"
else
    echo "Error: Could not locate icon files. Please build or install the Flatpak addon first." >&2
    exit 1
fi

echo "Installing icons to ~/.local/share/icons/hicolor/..."

# Target sizes including KDE Plasma tray sizes (22x22, 24x24)
for size in 16 22 24 32 48 64 128 256 512 1024; do
    target_dir="$HOME/.local/share/icons/hicolor/${size}x${size}/apps"
    mkdir -p "$target_dir"

    if [ "$SRC_MODE" = "flatpak_tree" ]; then
        if [ -f "$BASE_SRC/${size}x${size}/apps/openbangla-keyboard.png" ]; then
            cp "$BASE_SRC/${size}x${size}/apps/openbangla-keyboard.png" "$target_dir/openbangla-keyboard.png"
        elif [ -f "$BASE_SRC/32x32/apps/openbangla-keyboard.png" ]; then
            cp "$BASE_SRC/32x32/apps/openbangla-keyboard.png" "$target_dir/openbangla-keyboard.png"
        fi
    else
        if [ -f "$BASE_SRC/${size}.png" ]; then
            cp "$BASE_SRC/${size}.png" "$target_dir/openbangla-keyboard.png"
        elif [ -f "$BASE_SRC/32.png" ]; then
            cp "$BASE_SRC/32.png" "$target_dir/openbangla-keyboard.png"
        fi
    fi
done

# Install pixmaps
mkdir -p "$HOME/.local/share/pixmaps"
if [ "$SRC_MODE" = "flatpak_tree" ] && [ -f "$BASE_SRC/48x48/apps/openbangla-keyboard.png" ]; then
    cp "$BASE_SRC/48x48/apps/openbangla-keyboard.png" "$HOME/.local/share/pixmaps/openbangla-keyboard.png"
elif [ -f "$BASE_SRC/48.png" ]; then
    cp "$BASE_SRC/48.png" "$HOME/.local/share/pixmaps/openbangla-keyboard.png"
fi

# Install desktop shortcut
DESKTOP_DIR="$HOME/.local/share/applications"
mkdir -p "$DESKTOP_DIR"
cat > "$DESKTOP_DIR/openbangla-keyboard.desktop" << 'EOF'
[Desktop Entry]
Name=OpenBangla Keyboard
Comment=An OpenSource, Unicode compliant Bengali Input Method
Exec=flatpak run --command=/app/addons/OpenBangla/bin/openbangla-gui org.fcitx.Fcitx5
Icon=openbangla-keyboard
Terminal=false
Type=Application
Categories=Utility;Settings;
EOF

# Update desktop & icon caches
if command -v gtk-update-icon-cache >/dev/null 2>&1; then
    gtk-update-icon-cache -f -t "$HOME/.local/share/icons/hicolor" 2>/dev/null || true
fi

if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
fi

if command -v kbuildsycoca6 >/dev/null 2>&1; then
    kbuildsycoca6 2>/dev/null || true
elif command -v kbuildsycoca5 >/dev/null 2>&1; then
    kbuildsycoca5 2>/dev/null || true
fi

echo "Done! Icons and desktop entry installed successfully."
