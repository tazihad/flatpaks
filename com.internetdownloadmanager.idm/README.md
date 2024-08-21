### Install IDM flatpak
```
curl -L -o idm.flatpak https://github.com/tazihad/flatpaks/releases/download/flatpak/idm.flatpak
flatpak install --user org.winehq.Wine
flatpak install --user ./idm.flatpak
```

### Extension support

1. [Install Extension](https://add0n.com/download-by.html)
2. download script:
    ```
    curl -L https://raw.githubusercontent.com/tazihad/idm-linux/master/flatpak-idm -o ~/.local/bin/idm
    chmod +x ~/.local/bin/idm
    ```
3. df
