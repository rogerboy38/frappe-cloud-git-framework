#!/bin/bash
# quick_restore.sh - One-command setup for fresh Frappe Cloud benches

echo "╔══════════════════════════════════════════════════════╗"
echo "║     F R A P P E   C L O U D   Q U I C K   S E T U P  ║"
echo "╚══════════════════════════════════════════════════════╝"

# Step 1: SSH Setup
echo ""
echo "🔑 STEP 1: Creating SSH key..."
mkdir -p ~/.ssh
ssh-keygen -t ed25519 -C "frappe@github" -f ~/.ssh/id_ed25519 -N "" -q
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_ed25519

echo ""
echo "════════════════════════════════════════════════════════"
echo "📋 COPY THIS KEY TO GITHUB:"
echo "════════════════════════════════════════════════════════"
cat ~/.ssh/id_ed25519.pub
echo "════════════════════════════════════════════════════════"
echo ""
echo "👉 Go to: https://github.com/settings/keys"
echo "   Add key → Title: 'Frappe Cloud $(date +%Y-%m-%d)'"
read -p "✅ Press Enter after adding key..."

# Step 2: Git Config
echo ""
echo "📝 STEP 2: Git configuration..."
git config --global user.name "rogerboy38"
git config --global user.email "rogerboy38@hotmail.com"

# Step 3: Test
echo ""
echo "🔗 STEP 3: Testing connection..."
ssh -T git@github.com

# Step 4: Create manager script
echo ""
echo "⚡ STEP 4: Creating Git manager..."
cat > ~/frappe-bench/git_manager.sh << 'GMEOF'
#!/bin/bash
# Auto-generated Git manager

APPS=("rnd_nutrition" "rnd_warehouse_management" "amb_w_tds")

show_menu() {
    echo "Select app:"
    for i in "${!APPS[@]}"; do
        echo "  $((i+1))) ${APPS[$i]}"
    done
    echo "  q) Quit"
    
    read -p "Choice: " choice
    
    case $choice in
        1) cd ~/frappe-bench/apps/rnd_nutrition && ./git_manager_frappe.sh ;;
        2) cd ~/frappe-bench/apps/rnd_warehouse_management && ./git_manager_frappe.sh ;;
        3) cd ~/frappe-bench/apps/amb_w_tds && ./git_manager_frappe.sh ;;
        q) exit 0 ;;
        *) echo "Invalid choice" ;;
    esac
}

show_menu
GMEOF

chmod +x ~/frappe-bench/git_manager.sh

# Step 5: Aliases
echo ""
echo "🎛️  STEP 5: Creating aliases..."
cat >> ~/.bashrc << 'ALIASES'

# === F R A P P E   C L O U D ===
alias bench-git='~/frappe-bench/git_manager.sh'
alias git-fix='cd ~/frappe-cloud-git-framework && ./scripts/frappe_git_core.sh'
alias ssh-show='cat ~/.ssh/id_ed25519.pub'
alias bench-refresh='curl -s https://raw.githubusercontent.com/rogerboy38/frappe-cloud-git-framework/main/quick_restore.sh | bash'
ALIASES

echo ""
echo "✅ S E T U P   C O M P L E T E !"
echo ""
echo "Commands:"
echo "  bench-git     - Git manager menu"
echo "  git-fix       - Fix Git issues"
echo "  ssh-show      - Show SSH key"
echo "  bench-refresh - Re-run this setup"
echo ""
echo "Run: source ~/.bashrc"
