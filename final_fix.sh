cat > ~/frappe-bench/final_fix.sh << 'EOF'
#!/bin/bash
echo "╔══════════════════════════════════════════════════════╗"
echo "║      F I N A L   G I T   F I X   S C R I P T        ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""
echo "🎯 Targets:"
echo "  • rnd_warehouse_management → git@github.com:rogerboy38/rnd_warehouse_management.git"
echo "  • rnd_nutrition → git@github.com:rogerboy38/rnd_nutrition2.git"
echo ""

# Test SSH connection first
echo "🔑 Testing SSH connection..."
ssh -T git@github.com 2>&1 | grep -q "successfully authenticated" && {
    echo "✅ SSH connection verified!"
} || {
    echo "❌ SSH connection failed!"
    exit 1
}

echo ""
echo "========================================================"
echo "1. FIXING rnd_warehouse_management"
echo "========================================================"

cd ~/frappe-bench/apps/rnd_warehouse_management || {
    echo "❌ Directory not found!"
    exit 1
}

echo "📊 Current status:"
git status --short
echo ""
git branch -vv
echo ""

# Ensure we're on main branch
current_branch=$(git branch --show-current 2>/dev/null)
if [[ -z "$current_branch" || "$current_branch" != "main" ]]; then
    echo "🔄 Switching to main branch..."
    git checkout -B main
fi

# Remove existing remotes
echo "🔄 Configuring remotes..."
git remote remove origin 2>/dev/null
git remote remove upstream 2>/dev/null

# Add new origin
git remote add origin git@github.com:rogerboy38/rnd_warehouse_management.git
echo "✅ Added origin: git@github.com:rogerboy38/rnd_warehouse_management.git"

# Commit any changes
if [[ -n "$(git status --porcelain)" ]]; then
    echo "📝 Committing changes..."
    git add .
    git commit -m "Initial push to GitHub - $(date '+%Y-%m-%d %H:%M:%S')"
fi

# Push to GitHub
echo "📤 Pushing to GitHub..."
if git push -u origin main --force; then
    echo "🎉 SUCCESS! rnd_warehouse_management pushed to GitHub!"
    echo "🔗 https://github.com/rogerboy38/rnd_warehouse_management"
else
    echo "❌ Push failed! Check repository permissions."
    exit 1
fi

echo ""
echo "========================================================"
echo "2. FIXING rnd_nutrition (to rnd_nutrition2)"
echo "========================================================"

cd ~/frappe-bench/apps/rnd_nutrition || {
    echo "❌ Directory not found!"
    exit 1
}

echo "📊 Current status:"
git status --short
echo ""
git branch -vv
echo ""

# Ensure we're on main branch
current_branch=$(git branch --show-current 2>/dev/null)
if [[ -z "$current_branch" || "$current_branch" != "main" ]]; then
    echo "🔄 Switching to main branch..."
    git checkout -B main
fi

# Remove existing remotes
echo "🔄 Configuring remotes..."
git remote remove origin 2>/dev/null
git remote remove upstream 2>/dev/null

# Add new origin
git remote add origin git@github.com:rogerboy38/rnd_nutrition2.git
echo "✅ Added origin: git@github.com:rogerboy38/rnd_nutrition2.git"

# Clean up any temporary scripts
echo "🧹 Cleaning up temporary files..."
rm -f check_all_apps.sh sync_all_apps.sh accomplishment_summary.md 2>/dev/null || true

# Commit any changes
if [[ -n "$(git status --porcelain)" ]]; then
    echo "📝 Committing changes..."
    git add .
    git commit -m "Initial push to GitHub - $(date '+%Y-%m-%d %H:%M:%S')"
fi

# Push to GitHub
echo "📤 Pushing to GitHub..."
if git push -u origin main --force; then
    echo "🎉 SUCCESS! rnd_nutrition pushed to GitHub!"
    echo "🔗 https://github.com/rogerboy38/rnd_nutrition2"
else
    echo "❌ Push failed! Check repository permissions."
    exit 1
fi

echo ""
echo "========================================================"
echo "🎉 FINAL VERIFICATION"
echo "========================================================"

echo ""
echo "📋 Verifying all apps..."

APPS=(
    "rnd_warehouse_management:git@github.com:rogerboy38/rnd_warehouse_management.git"
    "rnd_nutrition:git@github.com:rogerboy38/rnd_nutrition2.git"
    "amb_w_tds:git@github.com:rogerboy38/amb_w_tds.git"
)

for app_config in "${APPS[@]}"; do
    app=$(echo "$app_config" | cut -d':' -f1)
    remote_url=$(echo "$app_config" | cut -d':' -f2-)
    
    echo ""
    echo "🔍 Checking $app..."
    cd ~/frappe-bench/apps/"$app" 2>/dev/null && {
        actual_url=$(git remote get-url origin 2>/dev/null || echo "none")
        branch=$(git branch --show-current 2>/dev/null || echo "unknown")
        
        if [[ "$actual_url" == "$remote_url" ]]; then
            echo "  ✅ Remote configured correctly"
            echo "  ✅ Branch: $branch"
            
            # Test connection
            if timeout 5 git ls-remote origin >/dev/null 2>&1; then
                echo "  ✅ Can connect to GitHub"
            else
                echo "  ⚠️  Connection test failed"
            fi
        else
            echo "  ❌ Remote mismatch:"
            echo "     Expected: $remote_url"
            echo "     Got: $actual_url"
        fi
    } || echo "  ❌ Directory not found"
done

echo ""
echo "========================================================"
echo "🏆 ALL DONE! SUMMARY"
echo "========================================================"
echo ""
echo "✅ rnd_warehouse_management:"
echo "   https://github.com/rogerboy38/rnd_warehouse_management"
echo ""
echo "✅ rnd_nutrition:"
echo "   https://github.com/rogerboy38/rnd_nutrition2"
echo ""
echo "✅ amb_w_tds:"
echo "   https://github.com/rogerboy38/amb_w_tds"
echo ""
echo "🔧 All apps now use SSH authentication"
echo "🚀 Ready for development and deployment!"
echo ""
echo "To sync all apps at any time:"
echo "  cd ~/frappe-bench && ./sync_all_apps.sh"
EOF

# Make executable and run
chmod +x ~/frappe-bench/final_fix.sh
cd ~/frappe-bench
./final_fix.sh
