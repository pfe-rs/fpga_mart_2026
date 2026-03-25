#!/bin/bash
# PFE FPGA - Setup script for pushing to the fork
# Run this once from inside your cloned pfe_mart_2026 directory

set -e

KEY_DIR="$HOME/.ssh"
KEY_FILE="$KEY_DIR/pfe_deploy_key"
SSH_CONFIG="$HOME/.ssh/config"

# Create .ssh directory if it doesn't exist
mkdir -p "$KEY_DIR"
chmod 700 "$KEY_DIR"

# Write the deploy key
cat > "$KEY_FILE" << 'KEYEOF'
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
QyNTUxOQAAACBd179lpirKXitkwbr+ssaEIc6lrStK4R7lIVT4rT23vwAAAJj5Xgzk+V4M
5AAAAAtzc2gtZWQyNTUxOQAAACBd179lpirKXitkwbr+ssaEIc6lrStK4R7lIVT4rT23vw
AAAECqn/a64B3s2LF4/tfIzKPvJrUGSmpYaJS9mTkUKclqrV3Xv2WmKspeK2TBuv6yxoQh
zqWtK0rhHuUhVPitPbe/AAAAD3BmZS1mcGdhLWRlcGxveQECAwQFBg==
-----END OPENSSH PRIVATE KEY-----
KEYEOF
chmod 600 "$KEY_FILE"

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
    chmod 600 "$SSH_CONFIG"
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
echo "  git commit -m \"your message\""
echo "  git push -u fork your-name"
echo ""
