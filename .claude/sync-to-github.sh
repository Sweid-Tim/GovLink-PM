#!/bin/bash
# GovLink Vault → GitHub 自动同步脚本
# 每天北京时间 8:00 由 launchd 触发执行

set -e

VAULT_DIR="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/GovLinkPM"
cd "$VAULT_DIR" || { echo "❌ 无法进入 vault 目录"; exit 1; }

# 检查是否有变更
if git diff --quiet && git diff --cached --quiet && [[ -z $(git ls-files --others --exclude-standard) ]]; then
    echo "✅ 无变更，跳过提交"
    exit 0
fi

# Add all changes (tracked + untracked, respecting .gitignore)
git add -A

# Commit
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
git commit -m "auto sync ${TIMESTAMP}"

# Push
git push origin main 2>&1 || git push origin master 2>&1

echo "✅ 同步完成: ${TIMESTAMP}"
