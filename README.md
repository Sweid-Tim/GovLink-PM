# GovLink-PM

GovLink 团队项目管理知识库

---

## 📋 快速开始

### 1. 环境准备

- [下载 Obsidian](https://obsidian.md)
- [下载 Git](https://git-scm.com/downloads)

### 2. 克隆仓库

```bash
git clone https://github.com/Sweid-Tim/GovLink-PM.git
cd GovLink-PM
```

### 3. 用 Obsidian 打开

打开 Obsidian → "打开本地仓库" → 选择 `GovLink-PM` 文件夹

### 4. 安装推荐插件

在 Obsidian 设置 → 社区插件中搜索安装：
- **Git** - 直接在 Obsidian 内提交和推送
- **Templater** - 使用 Templates/ 里的模板
- **Calendar** - 日历视图
- **Dataview** - 查询和索引笔记

---

## 📁 目录结构

```
GovLink-PM/
├── Templates/          # 模板（出差、报销、公文等）
├── Others/
│   └── 项目部/        # 项目相关文件
├── wiki/
│   └── concepts/      # 概念/知识文档
├── README.md           # 本文件
└── .gitignore
```

---

## 📝 日常使用流程

### 按命令操作

```bash
# 一天开始时 - 拉取最新内容
git pull origin main

# 修改文件后 - 提交并推送
git add .
git commit -m "docs: 描述你的修改"
git push
```

### 在 Obsidian 中操作（推荐）

1. 编辑完笔记后，打开左侧 Git 面板
2. 点击"提交"按钮，输入修改说明
3. 点击"推送"按钮

---

## 🤝 团队规则

1. **每天提交** - 当天的笔记当天提交推送
2. **先拉再推** - 编辑前先 `git pull`，推送前也先 `git pull`
3. **分类存放** - 不同内容放到对应文件夹
4. **文件冲突** - 如果提示冲突，保留双方内容，删掉 `<<<<<<<` 标记后重新提交
5. **大文件** - 图片、PDF 等尽量压缩后再上传

---

## 🔐 权限

需要加入协作的同事，请在 GitHub 仓库 Settings → Collaborators 中添加。

---

## ❓ 常见问题

**Q: 提示 "conflict" 怎么办？**
A: 打开冲突文件，删除 `<<<<<<<`、`=======`、`>>>>>>>` 标记，保留需要的内容，然后 `git add` 再提交。

**Q: 不小心提交了不该提交的文件？**
A: 修改 `.gitignore` 忽略该文件，然后重新提交。

**Q: 推送失败提示 "non-fast-forward"？**
A: 先执行 `git pull --rebase`，再 `git push`。
