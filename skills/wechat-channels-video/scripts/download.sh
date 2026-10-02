#!/usr/bin/env bash
# Download a WeChat Channels (视频号) URL with yt-dlp-patch.
# Usage:
#   bash scripts/download.sh <url>
#   bash scripts/download.sh --cookies <cookies.txt> <url>
#   WECHAT_CHANNELS_OUT=~/Downloads bash scripts/download.sh <url>
# Env:
#   WECHAT_CHANNELS_VENV  — venv path (default: <skill>/.venv)
#   WECHAT_CHANNELS_OUT   — output dir (default: ./downloads)
# Never prints cookie file contents.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
VENV_DIR="${WECHAT_CHANNELS_VENV:-${SKILL_DIR}/.venv}"
OUT_DIR="${WECHAT_CHANNELS_OUT:-./downloads}"
COOKIES_FILE=""
BROWSER="chrome"
URL=""

usage() {
  cat <<USAGE
Usage: $(basename "$0") [--cookies <path>] [--browser <name>] [--out <dir>] <url>

  --cookies   Netscape cookies.txt (skip --cookies-from-browser)
  --browser   Browser for cookie export (default: chrome)
  --out       Output directory (default: ./downloads or \$WECHAT_CHANNELS_OUT)
  <url>       weixin.qq.com/sph/... or channels.weixin.qq.com/...

Requires: run scripts/setup.sh first (installs yt-dlp-patch into .venv).
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    --cookies)
      COOKIES_FILE="${2:-}"
      shift 2
      ;;
    --browser)
      BROWSER="${2:-chrome}"
      shift 2
      ;;
    --out)
      OUT_DIR="${2:-}"
      shift 2
      ;;
    --)
      shift
      break
      ;;
    -*)
      echo "error: unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
    *)
      if [[ -z "${URL}" ]]; then
        URL="$1"
      else
        echo "error: unexpected argument: $1" >&2
        exit 2
      fi
      shift
      ;;
  esac
done

if [[ -z "${URL}" ]]; then
  echo "error: URL required" >&2
  usage >&2
  exit 2
fi

YTDLP="${VENV_DIR}/bin/yt-dlp"
if [[ ! -x "${YTDLP}" ]]; then
  echo "error: yt-dlp not found at ${YTDLP}" >&2
  echo "       run: bash '${SCRIPT_DIR}/setup.sh'" >&2
  exit 1
fi

mkdir -p "${OUT_DIR}"
# Resolve to absolute for reporting (portable-ish)
if command -v realpath >/dev/null 2>&1; then
  OUT_ABS="$(realpath "${OUT_DIR}")"
else
  OUT_ABS="$(cd "${OUT_DIR}" && pwd)"
fi

COOKIE_ARGS=()
if [[ -n "${COOKIES_FILE}" ]]; then
  if [[ ! -f "${COOKIES_FILE}" ]]; then
    echo "error: cookies file not found: ${COOKIES_FILE}" >&2
    exit 1
  fi
  # Host check only — never print cookie values
  if command -v grep >/dev/null 2>&1; then
    if ! grep -q 'yuanbao\.tencent\.com' "${COOKIES_FILE}"; then
      echo "warn: cookies file has no yuanbao.tencent.com host; download may fail" >&2
      echo "      log into https://yuanbao.tencent.com/ in the browser, then re-export" >&2
    else
      echo "==> cookies: yuanbao.tencent.com present (values not shown)"
    fi
  fi
  COOKIE_ARGS=(--cookies "${COOKIES_FILE}")
else
  COOKIE_ARGS=(--cookies-from-browser "${BROWSER}")
  echo "==> cookies-from-browser: ${BROWSER}"
fi

TEMPLATE="${OUT_ABS}/%(title)s.%(ext)s"
echo "==> url: ${URL}"
echo "==> out: ${OUT_ABS}"

"${YTDLP}" "${COOKIE_ARGS[@]}" -o "${TEMPLATE}" "${URL}"

echo "==> download finished"
# List newest media under out (best-effort; do not fail the script)
if command -v find >/dev/null 2>&1; then
  find "${OUT_ABS}" -type f \( -name '*.mp4' -o -name '*.webm' -o -name '*.mkv' -o -name '*.m4a' \) -print 2>/dev/null \
    | while IFS= read -r f; do
        if command -v stat >/dev/null 2>&1; then
          # macOS stat vs GNU stat
          size="$(stat -f%z "$f" 2>/dev/null || stat -c%s "$f" 2>/dev/null || echo '?')"
        else
          size='?'
        fi
        echo "    ${f} (${size} bytes)"
      done
fi
