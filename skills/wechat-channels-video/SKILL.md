---
name: wechat-channels-video
description: >-
  微信视频号 / WeChat Channels download and parse. Use when the user shares a
  weixin.qq.com/sph or channels.weixin.qq.com link, or asks to 下载/解析 视频号.
---

下载微信视频号分享链接，并按需解析为结构化中文摘要。用户给出 `weixin.qq.com/sph/…` 或 `channels.weixin.qq.com` 链接、或说「下载视频号 / 解析视频号」时启用。

**完成标准：** 磁盘上有视频文件（汇报绝对路径与大小）；若要求解析，则交付结构化中文摘要。**永不打印 cookie 内容。**

## 前置条件

- 官方 `yt-dlp` / yoinks **无法**提取视频号；必须使用 **`yt-dlp-patch`**（注册 `WeChatChannelIE` / `wechat_channel`）。
- Cookie 需覆盖 **`yuanbao.tencent.com`**（通常还有 `.tencent.com`）。从已登录 [腾讯元宝](https://yuanbao.tencent.com/) 的浏览器导出。
- 优先在本机（尤其是 macOS）做 cookie 导出与下载。

## 步骤

### 1. 确认范围

确认 URL 为视频号（`sph` 短链或 `channels.weixin.qq.com`）。问一次用户要：**仅下载**、**仅解析**（文件已在本地）、还是 **两者都要**（说「下载并解析」或仅说解析且无现成文件时默认两者）。

### 2. 工具准备

在本 skill 目录旁发现或创建虚拟环境（**不要**把 `.venv` 提交进仓库）：

1. 若本 skill 目录下已有 `.venv` 且含 `yt-dlp`，直接复用。
2. 否则运行本 skill 内脚本：

```bash
bash "<skill_dir>/scripts/setup.sh"
```

`setup.sh` 会在 skill 目录创建 `.venv`、安装 `yt-dlp-patch`，并校验 extractor 列表中出现 `wechat_channel`（或等价名称）。

也可手动：

```bash
python3 -m venv "<skill_dir>/.venv"
"<skill_dir>/.venv/bin/pip" install -U yt-dlp-patch
"<skill_dir>/.venv/bin/yt-dlp" --list-extractors | grep -iE 'wechat|weixin'
```

### 3. Cookie

导出 Netscape 格式 cookie；**不要**把内容回显到聊天或日志。

优先用浏览器读取（Chrome）：

```bash
"<skill_dir>/.venv/bin/yt-dlp" --cookies-from-browser chrome --cookies "<cookies.txt>"
```

只检查主机名是否命中 `yuanbao.tencent.com`（布尔/计数即可）。若缺失：请用户在 Chrome 登录元宝后重新导出。

**macOS TCC：** 若报 `Operation not permitted` / 找不到 Chrome Cookies 库，请用户给 Terminal（或代理 App）开启 **完全磁盘访问权限** 后重试。备选：用户用「Get cookies.txt LOCALLY」在 yuanbao.tencent.com 页面导出后给出路径。

### 4. 下载

使用本 skill 脚本（推荐）：

```bash
bash "<skill_dir>/scripts/download.sh" '<url>'
# 或指定 cookie 文件：
bash "<skill_dir>/scripts/download.sh" --cookies '<cookies.txt>' '<url>'
```

默认输出到 `./downloads`（相对当前工作目录）；也可用环境变量 `WECHAT_CHANNELS_OUT` 或脚本参数改到 `~/Downloads`。

等价手动命令：

```bash
"<skill_dir>/.venv/bin/yt-dlp" --cookies-from-browser chrome \
  -o './downloads/%(title)s.%(ext)s' '<url>'
```

成功：退出码 0 且媒体文件非空。汇报绝对路径与大小。若出现「无法解析视频号链接」/ 401，先复查元宝 cookie，再考虑其他方案。

### 5. 解析（按需）

解析方式**可插拔**，不要写死某一种实现。见同目录 [`PARSE.md`](PARSE.md)：

- 默认：把视频交给当前环境可用的「看视频 / 多模态」能力，要求中文结构化摘要（大纲、要点、框架/工具、可操作结论）。
- 也可替换为本地 ASR + LLM、外部 API 等；以 `PARSE.md` 中的钩子约定为准。

交付简洁中文摘要（先给结论）。仅在用户要求时再写笔记文件。

## 范围外

- `wx_channels_download`（微信 PC + MITM）仅在 cookie/`yt-dlp-patch` 失败且用户明确选择时启用。
- 不要声称 yoinks 支持视频号。
- 未经用户要求，不要把 cookie 或视频上传到本机以外。
