set -euo pipefail

if [ -n "${1:-}" ]; then
  git switch "$1"
  exit 0
fi

BRANCHES=$(cat <(git branch) <(git branch --remotes) | grep --invert-match '^\*\|HEAD ->' | sed 's|^\s*||')
CHOSEN_BRANCH=$(fzf --reverse --info=inline --preview 'git show --color {}' <<<"$BRANCHES")
CLEAN_BRANCH_NAME=$(sed 's|^\s*.*/||' <<<"$CHOSEN_BRANCH")
git switch "$CLEAN_BRANCH_NAME"