#!/bin/bash

# Enhanced version with logging and error handling
set -euo pipefail  # Exit on error, undefined variable, pipe failure

LOG_FILE="/var/log/setup_onestream.log"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Check root
if [[ $EUID -ne 0 ]]; then
    log "ERROR: Root privileges required"
    exit 1
fi

# System update
log "Updating system packages..."
apt update -y && apt upgrade -y >> "$LOG_FILE" 2>&1
apt install -y git nano wget dos2unix >> "$LOG_FILE" 2>&1

# Clone repository with error handling
log "Cloning repository..."
if [[ -d "onestream" ]]; then
    log "Repository exists, removing old version..."
    rm -rf onestream
fi

git clone https://github.com/onixsat/onestream.git || {
    log "ERROR: Failed to clone repository"
    exit 1
}

# Convert line endings
log "Converting line endings..."
dos2unix fox/* 2>/dev/null || true
find . -name '*.sh' -print0 | xargs -0 dos2unix 2>/dev/null || true

# Execute main script
log "Running btk.sh..."
cd onestream && bash btk.sh

log "Setup completed successfully"
