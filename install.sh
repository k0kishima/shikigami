#!/bin/bash

# Shikigami Installation Script
# https://github.com/k0kishima/shikigami

set -e

echo "Installing Shikigami..."

# Determine installation directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SHIKIGAMI_HOME="$SCRIPT_DIR"

# Check if Claude Code is installed
if ! command -v claude &> /dev/null; then
  echo ""
  echo "Warning: Claude Code is not installed."
  echo "Shikigami requires Claude Code to run."
  echo "Please install it from: https://claude.ai/code"
  echo ""
fi

# Determine shell configuration file
SHELL_CONFIG=""
if [ -n "$ZSH_VERSION" ] || [ "$SHELL" = "/bin/zsh" ]; then
  SHELL_CONFIG="$HOME/.zshrc"
elif [ -n "$BASH_VERSION" ] || [ "$SHELL" = "/bin/bash" ]; then
  if [ -f "$HOME/.bash_profile" ]; then
    SHELL_CONFIG="$HOME/.bash_profile"
  else
    SHELL_CONFIG="$HOME/.bashrc"
  fi
fi

# Add to PATH and set SHIKIGAMI_HOME
echo ""
echo "Adding Shikigami to your PATH..."

# Check if already configured
if grep -q "SHIKIGAMI_HOME" "$SHELL_CONFIG" 2>/dev/null; then
  echo "Shikigami is already configured in $SHELL_CONFIG"
else
  echo "" >> "$SHELL_CONFIG"
  echo "# Shikigami" >> "$SHELL_CONFIG"
  echo "export SHIKIGAMI_HOME=\"$SHIKIGAMI_HOME\"" >> "$SHELL_CONFIG"
  echo "export PATH=\"\$SHIKIGAMI_HOME/bin:\$PATH\"" >> "$SHELL_CONFIG"
  echo "Added configuration to $SHELL_CONFIG"
fi

echo ""
echo "Installation complete!"
echo ""
echo "To start using Shikigami, either:"
echo "  1. Open a new terminal, or"
echo "  2. Run: source $SHELL_CONFIG"
echo ""
echo "Then navigate to your project directory and run:"
echo "  shikigami"
echo ""
