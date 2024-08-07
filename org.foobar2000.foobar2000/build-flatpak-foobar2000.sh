#!/bin/bash

if [ -f "./foobar2000.flatpak" ]; then rm ./foobar2000.flatpak; fi


echo "Building with flatpak builder..."
flatpak run org.flatpak.Builder --force-clean foobar2000 org.foobar2000.foobar2000.yml >/dev/null
echo "✓ Done"

echo "Running flatpak build-export..."
flatpak build-export export foobar2000 >/dev/null
echo "✓ Done"

echo "Running flatpak build-bundle..."
flatpak build-bundle export foobar2000.flatpak org.foobar2000.foobar2000 >/dev/null
echo "✓ Done"




echo "Cleanup..."
if [ -d "./.flatpak-builder" ]; then rm -rf ./.flatpak-builder; fi
if [ -d "./export" ]; then rm -rf ./export; fi
if [ -d "./foobar2000" ]; then rm -rf ./foobar2000; fi
echo "✓ Done"

