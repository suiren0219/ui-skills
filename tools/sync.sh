#!/usr/bin/env bash
# 单向同步：本机 skill 源目录 -> 本仓库。
# 仓库是分发副本，永远不要把这里的改动反向覆盖回本机。
#
# 用法：
#   tools/sync.sh          复制并覆盖仓库中的对应 skill
#   tools/sync.sh --check  只比较差异，不写文件
#
# 源目录可用环境变量覆盖：
#   ZCODE_SKILLS     默认 ~/.zcode/skills
#   CLI_HOME_SKILLS  默认 /d/zcode/cli-home/skills
#   AGENTS_SKILLS    默认 ~/.agents/skills
#
# 注意：nexioui-lib 由本仓库直接维护（上游是 HaoZai000/NexioUI 只读源），
# 不经本脚本同步；本机没有它的源目录。新增此类「仓库自维护」skill 时在此登记。

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ZCODE_SKILLS="${ZCODE_SKILLS:-$HOME/.zcode/skills}"
CLI_HOME_SKILLS="${CLI_HOME_SKILLS:-/d/zcode/cli-home/skills}"
AGENTS_SKILLS="${AGENTS_SKILLS:-$HOME/.agents/skills}"

CHECK=0
if [[ "${1:-}" == "--check" ]]; then
  CHECK=1
fi

# 发布前脱敏：本机项目路径 -> 公开仓库地址
sanitize() {
  local file="$1"
  if [[ -f "$file" ]]; then
    sed -i 's#`D:/ai-projects/NexioSchedule`（分支 #`NexioSchedule`（https://github.com/suiren0219/NexioSchedule，分支 #g' "$file"
  fi
}

sync_skill() {
  local name="$1" src="$2"
  if [[ ! -d "$src" ]]; then
    echo "skip  $name: 源目录不存在 ($src)"
    return 0
  fi

  if [[ $CHECK -eq 1 ]]; then
    # 在临时副本上做同样的脱敏，避免把“已发布版本”误报为差异
    local tmp
    tmp="$(mktemp -d)"
    cp -rL "$src/." "$tmp/"
    sanitize "$tmp/SKILL.md"
    if diff -rq "$tmp" "$REPO_ROOT/$name" >/dev/null 2>&1; then
      echo "ok    $name"
    else
      echo "diff  $name"
      diff -rq "$tmp" "$REPO_ROOT/$name" 2>&1 | sed 's/^/      /'
    fi
    rm -rf "$tmp"
    return 0
  fi

  mkdir -p "$REPO_ROOT/$name"
  for item in SKILL.md references assets; do
    if [[ -e "$src/$item" ]]; then
      cp -rL "$src/$item" "$REPO_ROOT/$name/"
    fi
  done
  sanitize "$REPO_ROOT/$name/SKILL.md"
  echo "sync  $name"
}

# czero-ui / ksu-ui 优先取 .zcode 副本；nexio-ui 是软链，同样可用
sync_skill ksu-ui "$ZCODE_SKILLS/ksu-ui"
sync_skill czero-ui "$ZCODE_SKILLS/czero-ui"
sync_skill nexio-ui "$ZCODE_SKILLS/nexio-ui"
sync_skill fruit-flavor-design "$AGENTS_SKILLS/fruit-flavor-design"
sync_skill rust-desktop-ui "$AGENTS_SKILLS/rust-desktop-ui"

if [[ $CHECK -eq 0 ]]; then
  echo
  echo "同步完成。检查差异后提交："
  echo "  git -C \"$REPO_ROOT\" status --short"
  echo "提醒：showcase/ 与 README/USAGE 不由本脚本维护。"
fi
