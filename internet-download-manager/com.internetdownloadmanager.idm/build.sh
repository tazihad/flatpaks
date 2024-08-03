#!/bin/bash

if [ -f "./idm.flatpak" ]; then rm ./idm.flatpak; fi


echo "Building with flatpak builder..."
flatpak run org.flatpak.Builder --force-clean idm com.internetdownloadmanager.idm.yml >/dev/null
echo "✔️ Done"

echo "Running flatpak build-export..."
flatpak build-export export idm >/dev/null
echo "✔️ Done"

echo "Running flatpak build-bundle..."
flatpak build-bundle export idm.flatpak com.internetdownloadmanager.idm >/dev/null
echo "✔️ Done"




echo "Cleanup..."
if [ -d "./.flatpak-builder" ]; then rm -rf ./.flatpak-builder; fi
if [ -d "./export" ]; then rm -rf ./export; fi
if [ -d "./idm" ]; then rm -rf ./idm; fi
echo "✔️ Done"

