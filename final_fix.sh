#!/bin/bash
echo "=== FINAL FIX ==="

echo ""
echo "1. 🔧 Fixing frappe-cloud-git-framework..."
cd ~/frappe-cloud-git-framework

# Make sure we have README.md
if [[ ! -f README.md ]]; then
    echo "# Frappe Cloud Git Framework" > README.md
fi

# Add all files
git add .

# Commit if needed
if [[ -n "$(git status --porcelain)" ]]; then
    git commit -m "Add framework files"
fi

# Check branch
CURRENT_BRANCH=$(git branch --show-current)
if [[ "$CURRENT_BRANCH" != "main" ]]; then
    echo "Renaming branch from $CURRENT_BRANCH to main..."
    git branch -m main
fi

# Push
echo "Pushing to GitHub..."
if git push -u origin main; then
    echo "✅ Framework pushed successfully!"
else
    echo "⚠️  Push failed. Creating repository first..."
    echo ""
    echo "Go to: https://github.com/new"
    echo "Repository name: frappe-cloud-git-framework"
    echo "DO NOT initialize with README"
    echo "Click 'Create repository'"
    echo ""
    read -p "After creating repository, press Enter..."
    
    git push -u origin main && echo "✅ Success!" || echo "❌ Still failing"
fi

echo ""
echo "2. 🔧 Fixing amb_w_tds..."
cd ~/frappe-bench/apps/amb_w_tds

# Add the fix_detached.sh file if it exists
if [[ -f fix_detached.sh ]]; then
    git add fix_detached.sh
    git commit -m "Add fix script" 2>/dev/null || true
fi

# Try push with force (since you have local changes you want to keep)
echo "Pushing changes..."
if git push origin main --force-with-lease; then
    echo "✅ amb_w_tds pushed successfully!"
else
    echo "⚠️  Push failed. Trying different approach..."
    
    # Check if repo exists
    if curl -s -I https://github.com/rogerboy38/amb_w_tds | head -1 | grep -q "200"; then
        echo "Repository exists but has different history."
        echo "Creating backup branch..."
        git checkout -b backup-$(date +%Y%m%d)
        git push -u origin backup-$(date +%Y%m%d)
        echo "✅ Created backup branch"
    else
        echo "Repository might not exist. Creating..."
        git push -u origin main
    fi
fi

echo ""
echo "🎉 DONE!"
echo ""
echo "Your repositories:"
echo "  Framework: https://github.com/rogerboy38/frappe-cloud-git-framework"
echo "  amb_w_tds: https://github.com/rogerboy38/amb_w_tds"
