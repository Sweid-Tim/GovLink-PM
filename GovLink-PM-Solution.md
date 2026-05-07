# GovLink Obsidian 团队协作方案

## 一、仓库结构

```
GovLink-PM/
├── .gitignore                 # Git 忽略配置
├── CLAUDE.md                  # AI 助手说明
├── README.md                  # 仓库说明
│
├── .obsidian/                 # ⚠️ 部分同步，部分忽略
│   ├── core-plugins.json      # ✅ 同步 - 启用的插件
│   ├── community-plugins.json  # ✅ 同步 - 社区插件列表
│   ├── community-plugins/      # ❌ 忽略 - 插件缓存
│   ├── workspace.json         # ❌ 忽略 - 窗口状态，容易冲突
│   ├── workspace-mobile.json  # ❌ 忽略 - 移动端状态
│   └── *.json                 # ⚠️ 按需同步
│
├── 00-Templates/              # 模板库
│   ├── Daily-Note.md
│   ├── Meeting.md
│   ├── Project-Kickoff.md
│   ├── Task.md
│   ├── Person.md
│   └── Decision.md
│
├── 01-Daily/                  # 每日笔记 (自动命名: YYYY-MM-DD)
│   ├── 2026-05-07.md
│   └── 2026-05-06.md
│
├── 02-Projects/               # 项目笔记
│   ├── active/                # 正在进行
│   │   ├── project-alpha.md
│   │   └── project-beta.md
│   └── archived/             # 已完成归档
│
├── 03-Areas/                  # 责任领域
│   ├── engineering.md
│   ├── product.md
│   └── marketing.md
│
├── 04-Resources/              # 资源库
│   ├── notes/                 # 读书笔记、学习资料
│   ├── docs/                 # 外部文档链接
│   └── assets/               # 图片等资源
│
├── 05-Tasks/                  # 任务汇总
│   ├── inbox.md              # 收件箱（新任务）
│   └── scheduled/            # 计划任务
│
└── 99-Archive/               # 归档区
```

## 二、文件命名规范

| 类型 | 格式 | 示例 |
|------|------|------|
| 每日笔记 | `YYYY-MM-DD` | `2026-05-07.md` |
| 项目笔记 | `project-{name}` | `project-alpha.md` |
| 会议记录 | `{date}-{project}-{topic}` | `2026-05-07-alpha-planning.md` |
| 任务笔记 | `task-{id}-{short-desc}` | `task-001-fix-login.md` |
| 人物笔记 | `person-{name}` | `person-zhangsan.md` |
| 决策记录 | `decision-{YYYYMMDD}-{topic}` | `decision-20260507-db选型.md` |

## 三、Git 工作流

### 分支策略

```
main          ──────●────────●────────────  (生产环境)
                    \      /
feature/           ●───●                   (功能分支)
                             
review/                            ●──●   (需要 review 的内容)
```

### 操作流程

```bash
# 1. 每天开始工作 - 拉取最新
git pull origin main

# 2. 创建当日分支 (基于 main)
git checkout -b daily/2026-05-07

# 3. 编辑笔记...
# 4. 提交当日笔记
git add .
git commit -m "docs: add daily notes for 2026-05-07"

# 5. 推送到远程
git push origin daily/2026-05-07

# 6. 合并到 main (通过 PR 或直接合并)
git checkout main
git merge daily/2026-05-07
git push origin main
```

### 多人协作规则

1. **每日笔记**：每人创建独立分支，避免冲突
2. **共享笔记**：如 `project-alpha.md`，编辑前先 pull，编辑后立即 commit+push
3. **模板文件**：任何人可更新，需在 PR 中说明
4. **.obsidian 配置**：仅管理员可修改

## 四、冲突处理

### 常见冲突场景

| 场景 | 策略 |
|------|------|
| 每日笔记冲突 | 保留双方内容，手动合并 |
| 项目笔记冲突 | 协商后由一人合并 |
| .obsidian 配置冲突 | 使用最新版本 |

### 冲突解决步骤

```bash
# 1. 拉取最新
git pull origin main

# 2. 遇到冲突？查看冲突文件
git status

# 3. 编辑冲突文件，删除 <<<<<<< >>>>>>> 标记
# 4. 标记已解决
git add <resolved-file>

# 5. 提交
git commit -m "fix: resolve conflict in project-alpha.md"
git push
```

## 五、Obsidian 插件推荐

### 必需插件 (团队协作)

| 插件 | 用途 |
|------|------|
| **Git** | 直接在 Obsidian 内提交/推送 |
| **Templater** | 强大的模板系统 |
| **Metadata Menu** | 标准化元数据 |
| **QuickAdd** | 快速创建笔记 |
| **Tag Wrangler** | 标签管理 |

### 推荐插件 (效率)

| 插件 | 用途 |
|------|------|
| **Dataview** | 查询和索引 |
| **Calendar** | 日历视图 |
| **Folder Note** | 文件夹说明 |
| **Obsidian Link Checker** | 检查死链 |

## 六、模板内容

### 每日笔记模板

```markdown
# {{date:YYYY-MM-DD}} {{time:HH:mm}}

## 今日目标
- [ ]

## 会议
-

## 任务完成
- [ ]

## 明日计划
- [ ]

## 备注

```

### 会议记录模板

```markdown
# 会议: {{title}}

**日期**: {{date:YYYY-MM-DD}}
**时间**: {{time:HH:mm}}
**参与人**:
**主持**:
**记录**:
**项目**: [[project-{{project}}]]

## 议程
1.

## 讨论内容


## 决议
1.

## 行动项
- [ ] **@TODO**  - **截止**: 

## 下次会议
- 日期:
- 议程:
```

### 项目启动模板

```markdown
# 项目: {{project_name}}

**状态**: 🟡 筹备中
**开始日期**: {{date}}
**负责人**: {{owner}}
**团队**: 
**关联项目**: 

## 项目背景


## 目标
1.

## 里程碑
| 阶段 | 日期 | 交付物 |
|------|------|--------|
| 启动 | YYYY-MM-DD |  |
| 执行 | YYYY-MM-DD |  |
| 验收 | YYYY-MM-DD |  |

## 资源


## 风险


## 相关文档
-
```

## 七、.gitignore 配置

```gitignore
# Obsidian 工作区状态 (每次打开都会变，导致冲突)
.obsidian/workspace.json
.obsidian/workspace-mobile.json

# 缓存
.obsidian/cache/
.obsidian/community-plugins/*.md
.obsidian/plugins/**

# 系统文件
.DS_Store
Thumbs.db

# 日志
*.log

# 临时文件
*.tmp
*.swp
```

## 八、标签系统

### 常用标签

| 标签 | 含义 |
|------|------|
| `#area/engineering` | 工程领域 |
| `#area/product` | 产品领域 |
| `#area/marketing` | 市场领域 |
| `#status/active` | 进行中 |
| `#status/blocked` | 被阻塞 |
| `#status/done` | 已完成 |
| `#priority/high` | 高优先级 |
| `#priority/medium` | 中优先级 |
| `#type/meeting` | 会议 |
| `#type/task` | 任务 |
| `#type/decision` | 决策 |

## 九、团队规范

### 提交信息规范

```
类型: 简短描述

类型标识:
- docs:    文档更新
- feat:    新增内容
- fix:     修复问题
- refactor: 重构
- style:   格式调整
```

### Commit 示例

```bash
git commit -m "docs: add meeting notes for 2026-05-07"
git commit -m "feat: add project-beta kickoff doc"
git commit -m "fix: correct project-alpha timeline"
```

## 十、快速开始

```bash
# 1. 克隆仓库
git clone https://github.com/Sweid-Tim/GovLink-PM.git
cd GovLink-PM

# 2. 安装 Obsidian (如果未安装)
# 下载: https://obsidian.md

# 3. 用 Obsidian 打开此文件夹作为 vault

# 4. 安装推荐插件 (在社区插件中搜索安装)
# - Git, Templater, Metadata Menu, QuickAdd, Dataview, Calendar

# 5. 配置 Git 插件
# Settings → Git → 设置仓库路径为此文件夹
# 设置自动提交频率 (建议: 5分钟)

# 6. 复制模板
# 将 00-Templates/ 下的模板配置到 Templater 插件
```

## 十一、注意事项

1. **不要同步 .obsidian/workspace.json** - 会导致大量冲突
2. **每日笔记用独立分支** - 减少合并冲突
3. **保持笔记原子性** - 一个笔记一个主题
4. **定期归档** - 将已完成项目移到 `02-Projects/archived/`
5. **善用双向链接** - `[[笔记名]]` 创建连接
