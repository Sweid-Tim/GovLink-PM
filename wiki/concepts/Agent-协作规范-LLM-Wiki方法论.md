---
uid: agent-collaboration-llm-wiki
tags: [agent, collaboration, method, wiki]
created: 2026-05-02
modified: 2026-05-02
author: hermes
type: concept
---

# Agent 协作规范 — LLM Wiki 方法论

> **最高优先级：幻觉防御**
> 引用 vault 内容前必须 read_file 验证；压缩 context 引用前重新验证；不知道就说不知道。

---

## 什么是 LLM Wiki

**核心问题**：每次提问，LLM 从零发现知识，没有积累。

**解决方案**：让 LLM 增量构建并维护一个持久的 wiki。知识编译一次，**持续保持最新**，不再每次重复推导。

**关键区别**：wiki 是一个**持久、复利的知识制品**。交叉引用已就位，矛盾已标记，综合已反映所有读过的东西。

---

## 三层架构

```
raw/sources/ ← 原始资料层（LLM只读不改，真理来源）
↓ ingest
wiki/        ← 维基层（LLM全权维护的结构化笔记）
↓ 查询
你的回答     ← 直接输出，不重复推导
```

### 子文件夹

- `raw/sources/` — 文章、PDF、播客、报告（只读不改）
- `wiki/concepts/` — 概念页（方法论、术语、原理）
- `wiki/summaries/` — 摘要页（书籍、文章、会议）
- `wiki/entities/` — 实体页（人物、公司、供应商）

---

## 幻觉预防（最高优先级）

### 三种幻觉场景

| 场景 | ❌ 错误 | ✅ 正确 |
|------|---------|---------|
| 假装读过 | "根据你上周分享的文章…" | 先 read_file wiki 相关页面 |
| 压缩后捏造 | "我记得材料里有…" | 确认 context 里真实存在 |
| 知识过时 | "我记得上次结论是…" | 去 wiki 查证，用最新内容 |

### 预防机制

1. **引用前置**：回答时引用具体文件路径
2. **先读后说**：涉及 vault 内容，先 tool call 验证
3. **不猜不估**：不知道就说不知道
4. **交叉验证**：关键结论检查两个以上来源

---

## Ingest 工作流

```
Step 1：确定资料位置
Step 2：放入 raw/sources/[日期]-[来源].md
Step 3：读取并分析（核心论点、数据、矛盾点）
Step 4：写入 wiki/concepts/ 或 summaries/ 或 entities/
Step 5：更新 wiki/log.md 和 index.md，加入交叉链接
Step 6：告知用户文件位置
```

---

## Query 工作流

```
Step 1：search_files 在 wiki/ 搜索相关关键词
Step 2：read_file 读取验证
Step 3：综合回答，引用文件路径
Step 4：判断是否需要更新 wiki
```

---

## Harness Engineering

- **Context 是消耗品**：session 是临时工作台，wiki 是持久记忆
- **重要东西必须写文件**，不能依赖 context 残留
- **工具调用**：`read_file`=回忆，`write_file`=写入，`search_files`=检索
- **Memory = 短期**，**Obsidian = 长期**，超容量立即写 Obsidian
- **压缩后必须重新验证**原文，防止幻觉补充

---

## Hard Rules（强制规则）

1. **raw/sources/ 只读不改** — 不可突破的真理来源边界
2. **提到 vault 内容必须先验证** — 不能凭印象回答
3. **私人内容绝对不进入团队库** — 铁律
4. **知识编译一次持续最新** — 不每次从零推导
5. **压缩过的 context 引用前重新验证** — 防止幻觉
6. **关键内容优先写 vault** — 不依赖 memory

---

## 多 Agent 权限分层

- **Tim（owner）**：全部权限
- **团队成员**：仅 wiki/ 写权限
- **外部协作者**：仅限特定共享目录
- **私人内容禁区**：`[[private/*]]` 禁止跨 agent 引用

---

## 快速加载

其他 agent 执行 `skill_view(name='obsidian-second-brain')` 即可加载完整规范。

**Skill 路径**：`~/.hermes/skills/note-taking/obsidian-second-brain/SKILL.md`
