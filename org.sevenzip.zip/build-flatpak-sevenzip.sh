#!/bin/bash

if [ -f "./sevenzip.flatpak" ]; then rm ./sevenzip.flatpak; fi


echo "Building with flatpak builder..."
flatpak run org.flatpak.Builder --force-clean sevenzip org.sevenzip.zip.yml >/dev/null
echo "✓ Done"

echo "Running flatpak build-export..."
flatpak build-export export sevenzip >/dev/null
echo "✓ Done"

echo "Running flatpak build-bundle..."
flatpak build-bundle export sevenzip.flatpak org.sevenzip.zip >/dev/null
echo "✓ Done"




echo "Cleanup..."
if [ -d "./.flatpak-builder" ]; then rm -rf ./.flatpak-builder; fi
if [ -d "./export" ]; then rm -rf ./export; fi
if [ -d "./sevenzip" ]; then rm -rf ./sevenzip; fi
echo "✓ Done"

