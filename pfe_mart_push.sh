#!/bin/bash
# PFE FPGA - Setup script for pushing to the fork
# Run this once from inside your cloned pfe_mart_2026 directory
# DO NOT run with sudo!

set -e

KEY_DIR="$HOME/.ssh"
KEY_FILE="$KEY_DIR/pfe_deploy_key"
SSH_CONFIG="$KEY_DIR/config"

# Create .ssh directory if it doesn't exist
mkdir -p "$KEY_DIR"
chmod 700 "$KEY_DIR"

# Write the deploy key
cat > "$KEY_FILE" << 'KEYEOF'
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
QyNTUxOQAAACAnrd4O0kN0HiyWsfPZWI4YnffyiSGi9XYrJsRGtNgjNgAAAJjNSIPGzUiD
xgAAAAtzc2gtZWQyNTUxOQAAACAnrd4O0kN0HiyWsfPZWI4YnffyiSGi9XYrJsRGtNgjNg
AAAECt2Js/o+nQLbe4HnTB1LPSB+QS9Wm/ONJADPmcLxF2nyet3g7SQ3QeLJax89lYjhid
9/KJIaL1dismxEa02CM2AAAAD3BmZS1mcGdhLWRlcGxveQECAwQFBg==
-----END OPENSSH PRIVATE KEY-----
KEYEOF
chmod 600 "$KEY_FILE"

# Create SSH config file if it doesn't exist
touch "$SSH_CONFIG"
chmod 600 "$SSH_CONFIG"

# Add SSH config entry so git uses this key for the fork
if ! grep -q "pfe-fpga" "$SSH_CONFIG" 2>/dev/null; then
    cat >> "$SSH_CONFIG" << 'CONFEOF'

# PFE FPGA deploy key
Host pfe-fpga
    HostName github.com
    User git
    IdentityFile ~/.ssh/pfe_deploy_key
    IdentitiesOnly yes
CONFEOF
fi

# Add the fork as a remote
if git remote | grep -q "^fork$"; then
    git remote set-url fork git@pfe-fpga:pfe-rs/fpga_mart_2026.git
else
    git remote add fork git@pfe-fpga:pfe-rs/fpga_mart_2026.git
fi

echo ""
echo "Setup complete! To push your work:"
echo ""
echo "  git checkout -b your-name"
echo "  # make your changes"
echo "  git add <files>"
echo '  git commit -m "your message"'
echo "  git push -u fork your-name"
echo ""
