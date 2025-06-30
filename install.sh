#!/bin/bash

# Load config (defines $DIR and $PROGRAM)
source "conf.sh"

PROGRAM_PREFIX=""

# Check if installation directory is in PATH
if ! echo "$PATH" | grep -q "$DIR"; then
    echo "Warning: '$DIR' is not in your PATH."
    echo "         To use this program add '$DIR' to PATH,"
    echo "         or manually run '$DIR/$PROGRAM'"
    echo
    PROGRAM_PREFIX="$DIR/"
fi

# Check for python3
command -v python3 >/dev/null || {
    echo "Error: python3 is not installed." >&2
    exit 1
}

# Ensure curl and gpg are installed
apt-get update -qq
apt-get install -qq -y curl gnupg || {
    echo "Error: Failed to install curl or gnupg" >&2
    exit 1
}

# Download and convert Kali Linux ASCII GPG key
echo "Installing Kali Linux GPG key..."
curl -fsSL "https://archive.kali.org/archive-key.asc" | gpg --dearmor -o /usr/share/keyrings/kali-archive-keyring.gpg || {
    echo "Failed to fetch or convert Kali GPG key." >&2
    exit 1
}

# Add Kali APT source list with signed-by option
echo "Setting up Kali repo..."
echo "deb [signed-by=/usr/share/keyrings/kali-archive-keyring.gpg] http://http.kali.org/kali kali-rolling main contrib non-free" | tee /etc/apt/sources.list.d/kali.list > /dev/null

# Update package list
echo "Updating package list..."
apt-get update -qq || {
    echo "APT update failed." >&2
    exit 1
}

# Install python3-apt
echo "Installing python3-apt..."
apt-get install -qq -y python3-apt || {
    echo "Failed to install python3-apt" >&2
    exit 1
}

# Install katoolin3.py
echo "Installing katoolin3.py..."
install -T -g root -o root -m 555 ./katoolin3.py "$DIR/$PROGRAM" || {
    echo "Failed to install katoolin3.py" >&2
    exit 1
}

echo
echo "katoolin3.py successfully installed!"
echo "Run it with: sudo $PROGRAM_PREFIX$PROGRAM"
exit 0
