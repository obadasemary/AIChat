#!/bin/bash

# install-template.sh
# Installs the VIPER Xcode template for AIChat project

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║      AIChat VIPER Template Installer                    ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

# Define paths
TEMPLATE_SOURCE="XcodeTemplate/VIPERTemplate.xctemplate"
TEMPLATE_DEST="$HOME/Library/Developer/Xcode/Templates/CustomTemplates/VIPERTemplate.xctemplate"

# Check if source template exists
if [ ! -d "$TEMPLATE_SOURCE" ]; then
    echo -e "❌ Template source not found: $TEMPLATE_SOURCE"
    echo "   Make sure you're running this script from the project root."
    exit 1
fi

echo "📦 Installing VIPER Template..."
echo ""

# Create destination directory if it doesn't exist
echo "   Creating templates directory..."
mkdir -p "$(dirname "$TEMPLATE_DEST")"

# Remove existing template if present
if [ -d "$TEMPLATE_DEST" ]; then
    echo -e "   ${YELLOW}⚠️  Existing template found, removing...${NC}"
    rm -rf "$TEMPLATE_DEST"
fi

# Copy template
echo "   Copying template files..."
cp -r "$TEMPLATE_SOURCE" "$TEMPLATE_DEST"

# Verify installation
if [ -d "$TEMPLATE_DEST" ]; then
    echo ""
    echo -e "${GREEN}✅ Template installed successfully!${NC}"
    echo ""
    echo "📍 Template location:"
    echo "   $TEMPLATE_DEST"
    echo ""
    echo "📝 Template files:"
    ls -1 "$TEMPLATE_DEST" | sed 's/^/   • /'
    echo ""

    # Check if Xcode is running
    if pgrep -x "Xcode" > /dev/null; then
        echo -e "${YELLOW}⚠️  Xcode is currently running${NC}"
        echo ""
        echo "Please restart Xcode to see the template:"
        echo "   1. Quit Xcode (⌘Q)"
        echo "   2. Reopen Xcode"
        echo ""
        echo "Or run: killall Xcode && open /Applications/Xcode.app"
    else
        echo -e "${GREEN}✅ Ready to use!${NC}"
    fi

    echo ""
    echo "🚀 Usage:"
    echo "   1. Open Xcode"
    echo "   2. Right-click 'AIChat/Core/' folder"
    echo "   3. Select 'New File...'"
    echo "   4. Choose 'Custom Templates' → 'VIPERTemplate'"
    echo ""
    echo "📚 Documentation:"
    echo "   • Quick Reference: QUICK_REFERENCE.md"
    echo "   • Setup Guide: TEMPLATE_SETUP.md"
    echo ""

    exit 0
else
    echo ""
    echo -e "❌ Installation failed"
    echo "   Could not copy template to: $TEMPLATE_DEST"
    exit 1
fi
