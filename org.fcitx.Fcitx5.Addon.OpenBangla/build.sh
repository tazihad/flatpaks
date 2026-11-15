#!/bin/bash
# Build script for OpenBangla Keyboard Fcitx5 Addon Flatpak
# Usage: ./build.sh [--no-install] [--no-bundle] [--clean]

set -euo pipefail

# Configuration
MANIFEST="org.fcitx.Fcitx5.Addon.OpenBangla.yml"
APP_ID="org.fcitx.Fcitx5.Addon.OpenBangla"
BUILD_DIR="build-dir"
REPO_DIR="repo"
STATE_DIR=".flatpak-builder"
OUT_DIR="out"
BUNDLE_NAME="fcitx5-openbangla.flatpak"

# Parse arguments
INSTALL=true
CREATE_BUNDLE=true
FORCE_CLEAN=false

for arg in "$@"; do
    case $arg in
        --no-install)
            INSTALL=false
            shift
            ;;
        --no-bundle)
            CREATE_BUNDLE=false
            shift
            ;;
        --clean)
            FORCE_CLEAN=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [--no-install] [--no-bundle] [--clean]"
            echo "  --no-install   Build and export to repo only, don't install"
            echo "  --no-bundle    Don't create flatpak bundle"
            echo "  --clean        Force clean build (remove build-dir and state)"
            exit 0
            ;;
        *)
            echo "Unknown option: $arg"
            exit 1
            ;;
    esac
done

# Colors for output
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m' # No Color

log() { printf "${BLUE}==>${NC} %s\n" "$*"; }
warn() { printf "${YELLOW}warn:${NC} %s\n" "$*"; }
die() { printf "${RED}error:${NC} %s\n" "$*"; exit 1; }

# Check if manifest exists
[[ -f "$MANIFEST" ]] || die "Manifest not found: $MANIFEST"

# Clean if requested
if [[ "$FORCE_CLEAN" == true ]]; then
    log "Cleaning previous build..."
    rm -rf "$BUILD_DIR" "$STATE_DIR" "$REPO_DIR" "$OUT_DIR" "$BUNDLE_NAME"
fi

# Create directories
mkdir -p "$BUILD_DIR" "$STATE_DIR" "$REPO_DIR" "$OUT_DIR"

# Build with flatpak-builder
BUILDER_ARGS=(
    --user
    --force-clean
    --ccache
    --install-deps-from=flathub
    --state-dir="$STATE_DIR"
    --repo="$REPO_DIR"
    --disable-rofiles-fuse
)

if [[ "$INSTALL" == true ]]; then
    BUILDER_ARGS+=(--install "$BUILD_DIR")
else
    BUILDER_ARGS+=(--install="$BUILD_DIR")
fi

log "Building $APP_ID..."
flatpak run org.flatpak.Builder "${BUILDER_ARGS[@]}" "$MANIFEST" 2>&1 | tee "$OUT_DIR/build.log"

log "Build completed successfully!"

# Create bundle if requested
if [[ "$CREATE_BUNDLE" == true ]]; then
    log "Creating flatpak bundle..."
    # Find the correct refspec
    REF=$(flatpak run --command=ostree org.flatpak.Builder refs --repo="$REPO_DIR" | grep "^runtime/$APP_ID" | head -1)
    if [[ -z "$REF" ]]; then
        REF=$(flatpak run --command=ostree org.flatpak.Builder refs --repo="$REPO_DIR" | grep "^app/$APP_ID" | head -1)
    fi
    if [[ -z "$REF" ]]; then
        die "Could not find refspec for $APP_ID in repo"
    fi
    flatpak build-bundle "$REPO_DIR" "$BUNDLE_NAME" "$REF"
    log "Bundle created: $BUNDLE_NAME"
fi

log "Done!"