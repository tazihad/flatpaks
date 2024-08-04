#!/bin/bash
export WINEPREFIX=/var/data/wine
export WINE="/app/bin/wine"
export WINE_C_DRIVE="${WINEPREFIX}/drive_c"
export IDM_DOWNLOAD_URL='https://www.7-zip.org/a/7z2407-x64.exe'
export IDM_LOCATION="${WINE_C_DRIVE}/Program Files/7-Zip/7zFM.exe"
USER_NAME=$(whoami)
export TEMP_DIR="${WINE_C_DRIVE}/users/${USER_NAME}/Temp"

echo "Checking if 7zip is installed..."
if [ ! -f "${IDM_LOCATION}" ]; then
    echo -e "7-zip not found.\nInstalling 7-zip..."
    mkdir -p "${TEMP_DIR}"
    curl -L "${IDM_DOWNLOAD_URL}" -o "${TEMP_DIR}/7z.exe"
    "${WINE}" "${TEMP_DIR}/7z.exe"
fi

"${WINE}" "${IDM_LOCATION}"
