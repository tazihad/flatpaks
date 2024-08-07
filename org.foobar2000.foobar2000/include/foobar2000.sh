#!/bin/bash
export WINEPREFIX=/var/data/wine
export WINE="/app/bin/wine"
export WINE_C_DRIVE="${WINEPREFIX}/drive_c"
export APP_NAME="foobar2000"
export APP_DOWNLOAD_URL='https://www.foobar2000.org/files/foobar2000_v2.1.5.exe'
export APP_BINARY_LOCATION="${WINE_C_DRIVE}/Program Files (x86)/foobar2000/foobar2000.exe"
USER_NAME=$(whoami)
export TEMP_DIR="${WINE_C_DRIVE}/users/${USER_NAME}/Temp"

echo "Checking if foobar2000 is installed..."
if [ ! -f "${APP_BINARY_LOCATION}" ]; then
    echo -e "foobar2000 not found.\nInstalling foobar2000..."
    mkdir -p "${TEMP_DIR}"
    curl -L "${APP_DOWNLOAD_URL}" -o "${TEMP_DIR}/foobar2000.exe"
    "${WINE}" "${TEMP_DIR}/foobar2000.exe"
fi

"${WINE}" "${APP_BINARY_LOCATION}"
