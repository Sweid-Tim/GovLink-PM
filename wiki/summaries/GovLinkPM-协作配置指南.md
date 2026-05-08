---
title: GovLinkPM 协作配置指南
tags: [summary, guide]
created: 2026-05-08
---

# GovLinkPM 协作配置指南

> 从零开始，配置 Obsidian + GitHub + Claude Code 协作环境。

---

## 第一步：注册 GitHub 账号

1. 打开 https://github.com/signup
2. 输入邮箱，设置密码，创建用户名
3. 验证邮箱
4. 把 **GitHub 用户名** 发给 Tim 添加到仓库协作者

收到邀请后，会收到一封 GitHub 通知邮件，确认加入即可。

---

## 第二步：下载安装 Obsidian

1. 打开 https://obsidian.md/download
2. 下载对应系统的版本（macOS / Windows）
3. 安装并打开

---

## 第三步：克隆仓库到本地

### 方式 A：使用终端（推荐 macOS/Linux）

```bash
# 打开终端，cd 到你想放项目的目录
cd ~/Documents

# 克隆仓库
git clone https://github.com/Sweid-Tim/GovLink-PM.git

# 进入目录
cd GovLink-PM
```

### 方式 B：使用 GitHub Desktop（适合不熟悉终端的用户）

1. 下载安装 https://desktop.github.com
2. 登录 GitHub 账号
3. File > Clone Repository > 选择 `GovLink-PM`
4. 选择本地存放路径

---

## 第四步：在 Obsidian 中打开仓库

1. 打开 Obsidian
2. **设置** > **关于** > **语言** 切换为中文（可选）
3. 点击左下角 **打开其他仓库** > **打开本地文件夹**
4. 选择刚才克隆的 `GovLink-PM` 文件夹
5. **信任作者并加载插件**

---

## 第五步：配置 Obsidian Git 自动同步

1. **设置** > **社区插件** > **Obsidian Git**（已预装，直接启用即可）
2. 确保以下设置已开启：

| 设置项 | 值 | 说明 |
|--------|-----|------|
| Auto commit and sync | ✅ 开启 | 自动提交并同步 |
| Auto commit after files changed | 5 分钟 | 每 5 分钟自动提交 |
| Auto push interval | 5 分钟 | 自动推送到 GitHub |
| Auto pull interval | 30 分钟 | 自动拉取同事更新 |
| Auto pull on boot | ✅ 开启 | 启动时拉取最新 |
| Pull before push | ✅ 开启 | 推送前先拉取 |

3. 配置 Git 认证，打开终端执行：

```bash
# 配置用户名和邮箱（替换成你自己的）
git config --global user.name "你的名字"
git config --global user.email "你的邮箱@example.com"

# 保存 GitHub 登录凭据到钥匙串
# 首次 push/pull 时会弹出浏览器窗口，登录 GitHub 授权即可
```

4. 验证同步：按左侧 Ribbon 栏的 **Obsidian Git 图标**，点击 **Push**

---

## 第六步：日常使用流程

### 查看和编辑笔记

- 左侧文件列表浏览 `raw/sources/`（原始资料）和 `wiki/`（知识库）
- 直接点击 `.md` 文件编辑
- 编辑后 Obsidian Git 会自动提交推送（5 分钟内）

### 手动同步

按 `Cmd + P` 输入以下命令：

- `Obsidian Git: Pull` — 拉取同事的最新修改
- `Obsidian Git: Push` — 推送自己的修改
- `Obsidian Git: Commit all changes` — 手动提交

### 查看同步状态

Obsidian 底部状态栏会显示：
- `✓ Synced at HH:MM` — 已同步
- `↻ Pushing...` — 正在推送
- 🟢 `main` — 当前分支名

---

## 第七步（可选）：安装 VS Code

如果需要编辑代码或高级操作：

1. 下载 https://code.visualstudio.com/download
2. 安装并打开
3. 安装推荐插件：
   - **Markdown All in One** — Markdown 编辑增强
   - **GitLens** — Git 历史可视化

---

## 第八步（可选）：安装 Claude Code

如果需要使用 AI 辅助管理知识库：

### 安装 Node.js（依赖）

1. 下载 https://nodejs.org （选择 LTS 版本）
2. 安装，打开终端验证：

```bash
node --version
npm --version
```

### 安装 Claude Code

```bash
npm install -g @anthropic-ai/claude-code
```

### 配置 Claude Code

在仓库目录下创建 `.claude/settings.local.json`：

```json
{
  "permissions": {
    "allow": [
      "git status",
      "git add",
      "git commit",
      "git push",
      "git pull",
      "cat",
      "ls",
      "Read",
      "Edit",
      "Write",
      "Grep",
      "Glob"
    ]
  }
}
```

### 启动 Claude Code

```bash
# 在 GovLink-PM 目录下
cd ~/Documents/GovLink-PM
claude
```

---

## 常见问题

### Q: 同步时提示认证失败？

```bash
# 重新登录 GitHub 认证
git config --global credential.helper osxkeychain
```

如果还不行，尝试用 VS Code 或 GitHub Desktop 先 pull 一次，会弹出登录窗口。

### Q: 冲突了怎么办？

Obsidian Git 会自动合并，如果出现冲突：
1. 打开有冲突的文件，搜索 `<<<<<<<` 标记
2. 保留需要的内容，删除标记符号
3. 保存文件后手动 commit

### Q: 不想用自动同步？

在 Obsidian Git 设置中关闭 **Auto commit and sync**，改为手动操作。

### Q: 忘记之前同步了什么？

- 在 Obsidian 中按 `Cmd + P` > `Obsidian Git: Open history`
- 或在终端执行 `git log --oneline` 查看提交历史

---

*最后更新: 2026-05-08*
