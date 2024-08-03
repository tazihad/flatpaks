#!/bin/bash
export WINEDLLPATH=/app/dlls/lib32:/app/dlls/lib
export WINEPREFIX=/var/data/wine
export WINE="/app/bin/wine"
export WINE_C_DRIVE="${WINEPREFIX}/drive_c"
export IDM_DOWNLOAD_URL='https://download.filepuma.com/files/download-managers/internet-download-manager/Internet_Download_Manager_v6.36%20Build%205.exe'
export IDM_LOCATION="${WINE_C_DRIVE}/Program Files (x86)/Internet Download Manager/IDMan.exe"
USER_NAME=$(whoami)
export TEMP_DIR="${WINE_C_DRIVE}/users/${USER_NAME}/Temp"

echo "Checking if Internet Download Manager is installed..."
if [ ! -f "${IDM_LOCATION}" ]; then
    echo -e "Internet Download Manager not found.\nInstalling best wine compatible version idman636build5..."
    mkdir -p "${TEMP_DIR}"
    curl -L "${IDM_DOWNLOAD_URL}" -o "${TEMP_DIR}/idm.exe"
    "${WINE}" "${TEMP_DIR}/idm.exe"
fi

"${WINE}" "${IDM_LOCATION}"
