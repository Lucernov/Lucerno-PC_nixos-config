#!/usr/bin/env bash
kitty --title "ComfyUI Status" bash -c "systemctl --user status comfyui; echo 'Press any key to close...'; read -n 1"
