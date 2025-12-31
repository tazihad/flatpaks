# info.keepass.KeePass2

build-instructions:

```
git clone --recurse-submodules git@github.com:tazihad/info.keepass.KeePass2.git
cd info.keepass.KeePass2
flatpak-builder --force-clean --user --install-deps-from=flathub --repo=repo --install build-dir info.keepass.KeePass2.yml
flatpak run info.keepass.KeePass2

flatpak build-bundle repo keepass2.flatpak info.keepass.KeePass2 --runtime-repo=https://flathub.org/repo/flathub.flatpakrepo
```
### TODO
Support plugins Many plugins doesn't work. 
