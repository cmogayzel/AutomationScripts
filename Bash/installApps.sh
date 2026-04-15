#!/bin/bash

##Charles Mogayzel

set -euo pipefail

LOG_FILE="/var/log/app_install_update.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

require_root() {
    if [[ $EUID -ne 0 ]]; then
        echo "Please run this script as root or with sudo."
        exit 1
    fi
}

install_chrome() {
if command -v google-chrome >/dev/null 2>&1; then
        log "Google Chrome is already installed."
        return
    fi

    log "Downloading Google Chrome..."
    TMP_DEB="/tmp/google-chrome-stable_current_amd64.deb"

    if command -v curl >/dev/null 2>&1; then
        curl -L -o "$TMP_DEB" "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
    elif command -v wget >/dev/null 2>&1; then
        wget -O "$TMP_DEB" "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
    else
        log "Neither curl nor wget is installed. Installing curl first..."
        apt-get update
        apt-get install -y curl
        curl -L -o "$TMP_DEB" "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
    fi

    log "Installing Google Chrome..."
    apt-get install -y "$TMP_DEB"

    rm -f "$TMP_DEB"
    log "Google Chrome installation completed."
}

update_apt() {
    log "Refreshing APT package library..."
    apt-get update

    log "Installing available updates..."
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

    log "Installing dependency and kernel-related updates..."
    DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y

    log "Removing unnecessary packages..."
    apt-get autoremove -y

    log "Cleaning package cache..."
    apt-get autoclean -y
}

refresh_snap() {
    if command -v snap >/dev/null 2>&1; then
        log "Refreshing Snap packages..."
        snap refresh
    else
        log "Snap is not installed. Skipping Snap refresh."
    fi
}

refresh_flatpak() {
    if command -v flatpak >/dev/null 2>&1; then
        log "Refreshing Flatpak application library..."
        flatpak update -y
    else
        log "Flatpak is not installed. Skipping Flatpak refresh."
    fi
}

main() {
    require_root
    log "Starting application installation and Linux update process..."

    update_apt
    install_chrome
    refresh_snap
    refresh_flatpak

    log "All tasks completed successfully."
}


main

