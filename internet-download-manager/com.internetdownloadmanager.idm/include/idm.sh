#!/bin/bash
export WINEDLLPATH=/app/dlls/lib32:/app/dlls/lib
export WINEPREFIX=/var/data/wine
export WINE="/app/bin/wine"
export WINE_C_DRIVE="${WINEPREFIX}/drive_c"
export WINBOX_DOWNLOAD_URL='https://mirror2.internetdownloadmanager.com/idman642build18.exe?v=lt&filename=idman642build18.exe'
export IDM_LOCATION="${WINE_C_DRIVE}/Program Files (x86)/Internet Download Manager/IDMan.exe"
export TEMP="${WINE_C_DRIVE}/windows/temp"

echo "Checking if Internet Download Manager is installed..."
if [ ! -f "${IDM_LOCATION}" ]; then
    echo "Internet Download Manager not found. Installing latest version..."
    wget -O "${TEMP}/idm.exe" "${WINBOX_DOWNLOAD_URL}"
    "${WINE}" "${TEMP}/idm.exe"
fi
echo "\$1: '$1' \$2: '$2'"

"${WINE}" "${IDM_LOCATION}"
