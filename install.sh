#!/bin/bash

source "conf.sh"

PROGRAM_PREFIX=""

# If the installation directory is not in PATH issue a warning:
if ! echo "$PATH" | grep -q "$DIR"; then
    echo "Warning: '$DIR' is not in your PATH."
    echo "         To use this program add '$DIR'"
    echo "         to your PATH or manually copy"
    echo "         katoolin3.py somewhere."
    echo
    PROGRAM_PREFIX="$DIR/"
fi

# Check if python3 is installed
/usr/bin/env python3 -V >/dev/null || {
    echo "Please install 'python3'" >&2
    exit 1
}

# Add the latest Kali GPG key (in binary format)
# Download and convert ASCII key to .gpg
echo "Downloading Kali Linux GPG key as ASCII and converting..."
curl -fsSL "https://archive.kali.org/archive-key.asc" | gpg --dearmor -o /usr/share/keyrings/kali-archive-keyring.gpg || {
    echo "Failed to fetch or convert Kali GPG key." >&2
    exit 1
}

}

# Add Kali Linux repo using [signed-by=...]
echo "Adding Kali repo..."
echo "deb [signed-by=$GPG_KEY_FILE] http://http.kali.org/kali kali-rolling main contrib non-free" | tee /etc/apt/sources.list.d/kali.list

# Update package list
echo "Updating package list..."
apt-get update -qq || {
    echo "APT update failed." >&2
    exit 1
}

# Install required Python APT bindings
echo "Installing dependencies..."
apt-get install -qq -y python3-apt || {
    echo "Dependency installation failed." >&2
    exit 1
}

# Install katoolin3.py
echo "Installing katoolin3.py..."
install -T -g root -o root -m 555 ./katoolin3.py "$DIR/$PROGRAM" || {
    echo "Failed to install katoolin3.py" >&2
    exit 1
}

echo "Successfully installed."
echo "Run it with: sudo $PROGRAM_PREFIX$PROGRAM"
exit 0
