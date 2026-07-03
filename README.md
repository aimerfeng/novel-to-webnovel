# novel-to-webnovel

翻译腔小说 → 中文网文风格的 Claude Code 多阶段改写技能。

> **EN** — A [Claude Code Skill](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview) that converts translated-novel prose (Japanese light-novel translations, MTL drafts, or your own manuscripts) into natural Chinese **webnovel** style. Five-stage pipeline: deterministic format cleanup (quote marks, furigana removal) → per-project style guide generation → user-approved sample → **parallel subagent rewriting in ~25KB chunks** → QA scripts & merge checklist. Three intensity levels (light polish / webnovel voice / full localization), with curated slang whitelist/blacklist and translation-ese removal tables. Ships with 3 standalone Perl tools (`chapter_map`, `format_clean`, `qa_check`) usable outside Claude. MIT licensed.
>
> Install: `git clone https://github.com/aimerfeng/novel-to-webnovel.git ~/.claude/skills/novel-to-webnovel` — then just ask Claude Code to "网文化" any novel file.

把日轻译稿、英文译稿、机翻稿或你自己的小说草稿，转换成自然的中文网文口感——去翻译腔、第一人称吐槽流、网感词点缀。采用「机械清理 → 风格定调 → 样例确认 → 分块并行改写 → 质量校验合并」五阶段流水线，几十万字的书也能稳定处理。

## 安装

```bash
# 个人技能（所有项目可用）
git clone https://github.com/aimerfeng/novel-to-webnovel.git ~/.claude/skills/novel-to-webnovel

# Windows
git clone https://github.com/aimerfeng/novel-to-webnovel.git "%USERPROFILE%\.claude\skills\novel-to-webnovel"
```

需要 `perl`（macOS/Linux 自带；Windows 上 Git Bash 自带）。

## 使用

在 Claude Code 里直接说：

> 把 D:\books\某小说.txt 网文化

或显式触发：`/novel-to-webnovel`

技能会先问你三件事（文本性质、网文化程度、处理范围），给出改写前后对照 preview 让你选档，确认样例后才放量并行改写。

## 三档程度

| 档位 | 做什么 |
|---|---|
| 轻度润色 | 标点转换、删假名注音、去翻译腔句式，不动味道 |
| 中度网文化 | + 第一人称吐槽流、短句节奏、网感词点缀（千字 ≤3 处），保留原作背景 |
| 重度本土化 | + 人名中文化（映射表先确认）、背景搬到中国、文化细节替换 |

## 结构

```
novel-to-webnovel/
├── SKILL.md                      # 主入口：五阶段流水线 + 边界规则
├── references/                   # 按需加载（渐进式披露）
│   ├── style-guide.md            # 三档定义、翻译腔清除表、网感词白/黑名单、对照示范库
│   ├── workflow-fullbook.md      # 大篇幅分块并行派发工作流（>5万字才加载）
│   └── checklist.md              # 交付前逐项检查
├── scripts/                      # 确定性操作交给脚本，只有输出进上下文
│   ├── format_clean.pl           # 「」→“” 、删假名注音、去段首缩进
│   ├── chapter_map.pl            # 章节结构探查 + 自动分块方案（offset/limit 直接可用）
│   └── qa_check.pl               # 残留标点/注音/黑名单词/翻译腔统计（带行号示例）
└── assets/
    └── style-template.md         # 项目风格规范模板（改写子代理唯一读的文件）
```

## 设计要点

- **先小后大**：先出千字样例让用户确认口感，再放量并行——避免整书返工
- **确定性交给脚本**：标点、注音、缩进这类机械转换不靠模型，零漏网
- **子代理自包含**：每个改写块的提示带完整规范路径 + 精确行区间 + 块界截断说明
- **质量兜底**：qa_check 扫残留，checklist 查人名一致性、块接缝、网感词密度

## 脚本单独使用

```bash
perl scripts/chapter_map.pl 小说.txt 25     # 章节结构 + 25KB/块分块建议
perl scripts/format_clean.pl 小说.txt 出.txt # 机械格式清理
perl scripts/qa_check.pl 出.txt             # 质量校验（退出码 0=干净）
```

## 注意

- 本技能默认**另存新文件**，不覆盖原文
- 请在你拥有相应权利的文本上使用（自写稿、自译稿、公版作品）
- 涉及未成年角色的露骨描写段落，模型无法改写；技能会预先定位并让你选择原样保留或跳过，避免流程中断

## License

MIT
