#!/bin/bash
# install_with_ai.sh - Install Frappe Cloud Git Framework with AI capabilities

echo "Installing Frappe Cloud Git Framework..."

# 1. Copy core scripts
echo "1. Installing core scripts..."
mkdir -p ~/bin
cp scripts/frappe_git_core.sh ~/bin/frappe-git
chmod +x ~/bin/frappe-git

# 2. Add to PATH
if [[ ":$PATH:" != *":$HOME/bin:"* ]]; then
    echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
    echo "✅ Added ~/bin to PATH"
fi

# 3. Create configuration
echo "2. Creating configuration..."
mkdir -p ~/.frappe_git
cp quick_restore.sh ~/frappe-bench/ 2>/dev/null || true

# 4. AI Integration
echo "3. Setting up AI integration..."
mkdir -p ~/.frappe_git/ai_plugins
cp ai-integration/* ~/.frappe_git/ai_plugins/ 2>/dev/null || true

# 5. Test installation
echo "4. Testing installation..."
if command -v frappe-git &> /dev/null; then
    echo "✅ Framework installed successfully!"
    echo ""
    echo "Quick commands:"
    echo "  frappe-git           - Analyze and fix Git issues"
    echo "  ~/frappe-bench/quick_restore.sh  - Setup fresh bench"
    echo ""
    echo "For AI integration:"
    echo "  Source: ~/.frappe_git/ai_plugins/ai_plugin_template.sh"
    echo "  Data:   ~/.frappe_git/ai_data/"
else
    echo "⚠️  Installation may need manual PATH setup"
fi

echo ""
echo "🎉 Installation complete!"
echo "Framework ready for AI agent integration."
