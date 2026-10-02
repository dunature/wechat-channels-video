#!/usr/bin/env bash
# Create a local .venv next to this skill and install yt-dlp-patch.
# Usage: bash scripts/setup.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
VENV_DIR="${WECHAT_CHANNELS_VENV:-${SKILL_DIR}/.venv}"

echo "==> skill dir: ${SKILL_DIR}"
echo "==> venv:      ${VENV_DIR}"

if ! command -v python3 >/dev/null 2>&1; then
  echo "error: python3 not found" >&2
  exit 1
fi

PY_VER="$(python3 -c 'import sys; print("%d.%d" % sys.version_info[:2])')"
echo "==> python:    ${PY_VER}"

if [[ ! -d "${VENV_DIR}" ]]; then
  echo "==> creating venv"
  python3 -m venv "${VENV_DIR}"
else
  echo "==> reusing existing venv"
fi

# shellcheck disable=SC1091
source "${VENV_DIR}/bin/activate"

python -m pip install -U pip
python -m pip install -U yt-dlp-patch

YTDLP="${VENV_DIR}/bin/yt-dlp"
if [[ ! -x "${YTDLP}" ]]; then
  echo "error: yt-dlp not found at ${YTDLP}" >&2
  exit 1
fi

echo "==> verifying WeChat Channels extractor"
if ! "${YTDLP}" --list-extractors | grep -iE 'wechat|weixin' >/dev/null; then
  echo "error: no wechat/weixin extractor listed; yt-dlp-patch may be missing" >&2
  exit 1
fi

"${YTDLP}" --list-extractors | grep -iE 'wechat|weixin' || true
echo "==> setup ok"
echo "    activate: source '${VENV_DIR}/bin/activate'"
echo "    download: bash '${SCRIPT_DIR}/download.sh' '<url>'"
