# wechat-channels-video

Agent skill: download and parse **WeChat Channels (微信视频号)** shares.

Works with [`npx skills`](https://skills.sh) / Claude Code / Codex / Cursor and other agents that load `SKILL.md`.

## Install

```bash
npx skills add dunature/wechat-channels-video
```

Or install one skill globally for Claude Code:

```bash
npx skills add dunature/wechat-channels-video -g -a claude-code -y
```

List skills in this repo without installing:

```bash
npx skills add dunature/wechat-channels-video --list
```

## Layout

```
skills/wechat-channels-video/
├── SKILL.md          # agent instructions (body: Chinese)
├── PARSE.md          # pluggable parse hooks
└── scripts/
    ├── setup.sh      # create .venv + install yt-dlp-patch
    └── download.sh   # download a Channels URL
```

## Manual setup (without an agent)

```bash
cd skills/wechat-channels-video
bash scripts/setup.sh
bash scripts/download.sh 'https://weixin.qq.com/sph/...'
```

Cookies: prefer Chrome logged into [腾讯元宝](https://yuanbao.tencent.com/). Never commit cookie files.

## Requirements

- Python 3.9+
- macOS or Linux
- `yt-dlp-patch` (installed by `setup.sh`) — stock `yt-dlp` cannot extract Channels

## License

MIT
