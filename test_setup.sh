#!/bin/bash
echo "=== SETUP VERIFICATION ==="

echo "1. SSH Test:"
if ssh -T git@github.com 2>&1 | grep -q "authenticated"; then
    echo "✅ SSH: Working"
else
    echo "❌ SSH: Failed"
fi

echo ""
echo "2. Git Config:"
echo "   Name: $(git config --global user.name)"
echo "   Email: $(git config --global user.email)"

echo ""
echo "3. amb_w_tds Status:"
cd ~/frappe-bench/apps/amb_w_tds 2>/dev/null && {
    echo "   Branch: $(git branch --show-current 2>/dev/null || echo 'unknown')"
    echo "   Remote: $(git remote get-url origin 2>/dev/null || echo 'none')"
}

echo ""
echo "4. Framework Status:"
cd ~/frappe-cloud-git-framework 2>/dev/null && {
    echo "   Files: $(find . -type f | wc -l)"
    echo "   Git: $(git rev-parse --is-inside-work-tree 2>/dev/null && echo 'initialized' || echo 'not initialized')"
}

echo ""
echo "=== SUMMARY ==="
if ssh -T git@github.com 2>/dev/null | grep -q "authenticated"; then
    echo "🎉 SSH is working! You can now push to GitHub."
else
    echo "⚠️  SSH still needs setup. Run steps 1-2 above."
fi
