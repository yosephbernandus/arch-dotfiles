#!/usr/bin/env bash
# hyprpaper 0.8.x ignores preload/wallpaper from the config file on this setup,
# so apply the wallpaper over IPC once hyprpaper is up. Requires ipc=on in hyprpaper.conf.
wallpaper="$HOME/.config/backgrounds/train-sideview.png"

for _ in $(seq 1 50); do
    if hyprctl hyprpaper listactive >/dev/null 2>&1; then
        hyprctl hyprpaper wallpaper ",$wallpaper"
        exit 0
    fi
    sleep 0.2
done

exit 1
