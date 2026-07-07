#!/bin/bash

###############################################################################
# System Setup and Security Check Script
# Runs initial system configuration, updates, installs tools, and performs scans
###############################################################################

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored messages
print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}============================================================${NC}"
}

# Check if running as root, if not use sudo
if [[ $EUID -ne 0 ]]; then
    if command -v sudo &> /dev/null; then
        SUDO_CMD="sudo"
    else
        print_error "This script must be run as root or with sudo"
        exit 1
    fi
else
    SUDO_CMD=""
fi


###############################################################################
# Step 1: Update and Upgrade System
###############################################################################
print_header "Step 1: Updating System Packages"

$SUDO_CMD apt update && $SUDO_CMD apt upgrade -y
print_message "System packages updated successfully"

###############################################################################
# Step 2: Install Required Tools
###############################################################################
print_header "Step 2: Installing Required Tools"

$SUDO_CMD apt-get install -y net-tools
print_message "net-tools installed successfully"

###############################################################################
# Step 3: Clone and Run System Checks
###############################################################################
print_header "Step 3: Running System Checks"

SYSTEM_CHECKS_DIR="/tmp/system-checks"
if [[ -d "$SYSTEM_CHECKS_DIR" ]]; then
    print_warning "system-checks directory already exists, removing..."
    rm -rf "$SYSTEM_CHECKS_DIR"
fi

print_message "Cloning system-checks repository..."
git clone https://github.com/m0zgen/system-checks.git "$SYSTEM_CHECKS_DIR"

cd "$SYSTEM_CHECKS_DIR"
print_message "Running system-check.sh with options -sn -sd -e..."
bash system-check.sh -sn -sd -e

###############################################################################
# Step 4: Clone and Run PortEye
###############################################################################
print_header "Step 4: Running PortEye Port Scan"

PORTEYE_DIR="/tmp/PortEye"
if [[ -d "$PORTEYE_DIR" ]]; then
    print_warning "PortEye directory already exists, removing..."
    rm -rf "$PORTEYE_DIR"
fi

print_message "Cloning PortEye repository..."
git clone https://github.com/s-r-e-e-r-a-j/PortEye.git "$PORTEYE_DIR"

cd "$PORTEYE_DIR"

ipaddr=$(curl v4.ident.me)

print_message "Running porteye.sh against target ${ipaddr} with ports 20 80..."
bash PortEye/porteye.sh ${ipaddr} 20 80

###############################################################################
# Step 5: Cleanup
###############################################################################
print_header "Step 5: Cleanup"

print_message "Cleaning up temporary directories..."
rm -rf "$SYSTEM_CHECKS_DIR" "$PORTEYE_DIR"

###############################################################################
# Script Complete
###############################################################################
print_header "Script Completed Successfully"


echo -e "${GREEN}All tasks completed!${NC}"
echo ""
echo "Summary:"
echo "  - System packages updated and upgraded"
echo "  - net-tools installed"
echo "  - System checks performed"
echo "  - Port scan completed on ${ipaddr} (ports 20, 80)"
