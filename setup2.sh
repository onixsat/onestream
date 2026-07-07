#!/bin/bash

# Exit on error
set -e

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root"
    exit 1
fi

# System update and package installation
echo "Updating system and installing packages..."
apt update -y && apt upgrade -y
apt install -y git nano wget dos2unix

# Clone repository
echo "Cloning repository..."
git clone https://github.com/onixsat/onestream.git

# Convert line endings
echo "Converting line endings..."
dos2unix fox/* 2>/dev/null || true
find . -name '*.sh' -print0 | xargs -0 dos2unix 2>/dev/null || true

# Enter directory and run script
cd onestream || exit 1
bash btk.sh
