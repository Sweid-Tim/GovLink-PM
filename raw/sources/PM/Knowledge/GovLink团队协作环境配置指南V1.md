# GovLink团队协作环境配置指南V1

---

## 一、注册GitHub账号并加入仓库

1. 打开 https://github.com/signup
2. 输入邮箱地址，设置密码，创建用户名
3. 完成邮箱验证
4. 将你的 **GitHub用户名** 发给管理员（Tim）
5. 管理员邀请后，登录GitHub接受邀请

---

## 二、安装所需软件

| 软件 | 下载地址 | 安装说明 |
|------|----------|----------|
| **Git** | https://git-scm.com/downloads | 下载后一路"Next"安装 |
| **Obsidian** | https://obsidian.md/download | 下载对应系统版本安装 |
| **Node.js** | https://nodejs.org | 下载LTS版本，一路安装 |

安装完成后，打开终端（macOS按 `Cmd+Space` 搜索"终端"；Windows按 `Win+R` 输入 `cmd`），运行以下命令安装 Claude Code：

```bash
npm install -g @anthropic-ai/claude-code
```

安装完成后验证：

```bash
node --version
npm --version
claude --version
```

---

## 三、克隆仓库到本地

打开终端，依次执行以下命令：

```bash
cd ~/Desktop
git clone https://github.com/Sweid-Tim/GovLink-PM.git
cd GovLink-PM
```

> 仓库下载完成后，桌面上会出现 `GovLink-PM` 文件夹。

---

## 四、打开并配置Obsidian

1. 打开 Obsidian
2. 点击左下角 **打开其他仓库** → **打开本地文件夹**
3. 选择桌面上的 `GovLink-PM` 文件夹
4. 弹出安全提示时，选择 **信任作者并加载插件**
5. Obsidian Git 插件已预装，会自动同步

日常使用：编辑笔记后，Obsidian Git 每5分钟自动同步到GitHub。

---

## 五、管理员的准备工作

> 以下由管理员（Tim）完成，团队成员无需操作。

1. 在GitHub创建私有仓库 `GovLink-PM`
2. 将整个Obsidian知识库推送到GitHub仓库
3. 配置Obsidian Git自动同步策略（每5分钟自动commit + push）
4. 将同事的GitHub账号添加为仓库 Collaborator
5. 配置git认证信息至macOS钥匙串

---

## 六、注意事项

1. **首次`git clone`** 时如果仓库较大，请耐心等待下载完成
2. 所有markdown文件尽量使用 **UTF-8编码**，文件名建议使用**纯英文命名**
3. **不要修改 `.obsidian` 文件夹**内的任何插件设置和配置文件
4. 如有问题，联系管理员（Tim）
