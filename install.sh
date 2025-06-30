#!/bin/bash

source "conf.sh"

PROGRAM_PREFIX=""

# Check if installation dir is in PATH
if ! echo "$PATH" | grep -q "$DIR"; then
    echo "Warning: '$DIR' is not in your PATH."
    echo "         To use this program add '$DIR'"
    echo "         to your PATH or manually copy"
    echo "         katoolin3.py somewhere."
    echo
    PROGRAM_PREFIX="$DIR/"
fi

# Check for python3
/usr/bin/env python3 -V >/dev/null || { echo "Please install 'python3'" >&2; exit 1; }

# Add Kali Linux GPG key (modern way)
GPG_KEY_URL="https://archive.kali.org/archive-key.asc"
GPG_KEY_FILE="/usr/share/keyrings/kali-archive-keyring.gpg"
echo "Fetching GPG key..."
curl -fsSL "$GPG_KEY_URL" | gpg --dearmor -o "$GPG_KEY_FILE" || {
    echo "Failed to fetch or store the GPG key." >&2
    exit 1
}

# Example APT source (make sure conf.sh handles this if needed)
# echo "deb [signed-by=$GPG_KEY_FILE] http://http.kali.org/kali kali-rolling main contrib non-free" | tee /etc/apt/sources.list.d/kali.list

# Update and install dependencies
apt-get update -qq || { echo "APT update failed." >&2; exit 1; }
apt-get install -qq -y python3-apt || { echo "Dependency installation failed." >&2; exit 1; }

# Install katoolin3
install -T -g root -o root -m 555 ./katoolin3.py "$DIR/$PROGRAM" || {
    echo "Failed to install katoolin3.py" >&2
    exit 1
}

echo "Successfully installed."
echo "Run it with 'sudo $PROGRAM_PREFIX$PROGRAM'."
exit 0
