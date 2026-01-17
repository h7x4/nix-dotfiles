set -euo pipefail

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ] || [ $# -ge 2 ]; then
  declare -r ARGV0=$(basename "${0:-git-switch-interactive.sh}")
  printf 'Usage: %s [BRANCH]\n' "$ARGV0" >&2
  cat <<'EOF' >&2
Interactively choose a local branch, remote branch, or tag to switch to.

Options:
  -h, --help        Show this help and exit
  BRANCH            If a single branch/tag/ref is provided, the script will
                    run git switch BRANCH and exit.
EOF
  exit 0
fi

if [ $# -eq 1 ]; then
  git switch "$1"
  exit 0
fi

declare -r BRANCH_COLOR=$'\033[32m'
declare -r REMOTE_COLOR=$'\033[33m'
declare -r ORIGIN_COLOR=$'\033[31m'
declare -r TAG_COLOR=$'\033[35m'
declare -r RESET_COLOR=$'\033[0m'

if [ -n "${NO_COLOR:-}" ]; then
  declare -r BRANCH_COLOR=''
  declare -r REMOTE_COLOR=''
  declare -r ORIGIN_COLOR=''
  declare -r TAG_COLOR=''
  declare -r RESET_COLOR=''
fi

declare -r STRIP_ANSI_SED='s/\x1B\[[0-9;]*[a-zA-Z]//g'
declare -r TRIM_SPACE_SED='s/^[[:space:]]+//; s/[[:space:]]+$//'
declare -r STRIP_SURROUNDING_QUOTES_SED="s/^[[:space:]\"'[]+//; s/[[:space:]\"'\\]]+\$//; s/^\"\\[+//; s/^\\[+//; s/\\]+$//"

sanitize_ref_from_git() {
  sed -E \
    -e "$STRIP_ANSI_SED" \
    -e "$TRIM_SPACE_SED" \
    -e "$STRIP_SURROUNDING_QUOTES_SED" <<<"$1"
}

declare -a VISIBLE_ITEMS=()

while IFS= read -r ref; do
  [ -z "$ref" ] && continue
  VISIBLE_ITEMS+=("${BRANCH_COLOR}(branch)${RESET_COLOR} $(sanitize_ref_from_git "$ref")")
done < <(git for-each-ref --sort=-committerdate --format='%(refname:short)' refs/heads 2>/dev/null)

while IFS= read -r ref; do
  [ -z "$ref" ] && continue
  case "$ref" in
    */*)
      remote_part="$(sanitize_ref_from_git "${ref%%/*}")"
      branch_part="$(sanitize_ref_from_git "${ref#*/}")"
      if [ -z "$branch_part" ] || [ "$branch_part" = "HEAD" ]; then
        continue
      fi
      VISIBLE_ITEMS+=("${REMOTE_COLOR}(remote)${RESET_COLOR} ${ORIGIN_COLOR}${remote_part}${RESET_COLOR}/${branch_part}")
      ;;
    *)
      continue
      ;;
  esac
done < <(git for-each-ref --format='%(refname:short)' refs/remotes 2>/dev/null)

while IFS= read -r ref; do
  [ -z "$ref" ] && continue
  VISIBLE_ITEMS+=("${TAG_COLOR}(tag)${RESET_COLOR} $(sanitize_ref_from_git "$ref")")
done < <(git for-each-ref --format='%(refname:short)' refs/tags 2>/dev/null)

if [ ${#VISIBLE_ITEMS[@]} -eq 0 ]; then
  echo "No branches or tags found." >&2
  exit 1
fi

declare -r SKIM_PREVIEW_COMMAND_RAW=$(cat <<'EOF'
raw=$(printf "%s" {} | sed -r 's/\x1B\[[0-9;]*[A-Za-z]//g')
ref=$(printf "%s" "$raw" | sed -n -E 's/^[[:space:]]*\([^)]*\)[[:space:]]*(.*)$/\1/p')
git show --color "$ref" 2>/dev/null || git log -n 50 --color "$ref"
EOF
)

declare -r SKIM_PREVIEW_COMMAND_=${SKIM_PREVIEW_COMMAND_RAW//$'\n'/'; '}
declare -r SKIM_PREVIEW_COMMAND=${SKIM_PREVIEW_COMMAND_%'; '}

CHOSEN=$(printf '%s\n' "${VISIBLE_ITEMS[@]}" | sk --ansi --reverse --info=inline --preview "$SKIM_PREVIEW_COMMAND")

[ -z "${CHOSEN:-}" ] && exit 0

declare -r CLEAN=$(sed -E \
  -e "$STRIP_ANSI_SED" \
  -e "$TRIM_SPACE_SED" \
  <<<"$CHOSEN"
)

declare -r PARSED=$(sed -n -E "s/^[[:space:]]*\(([^)]*)\)[[:space:]]*(.*)$/\1|\2/p" <<<"$CLEAN") || true
if [ -z "$PARSED" ]; then
  echo "Failed to parse selection: $CLEAN" >&2
  exit 2
fi

declare -r TYPE=${PARSED%%|*}
declare -r RAW_REF=${PARSED#*|}
declare -r REF=$(sanitize_ref_from_git "$RAW_REF")

case "$TYPE" in
  tag)
    git switch --detach "$REF"
    ;;
  remote)
    SWITCH_NAME="$REF"
    for R in $(git remote 2>/dev/null); do
      if [ "${REF#"${R}"/}" != "$REF" ]; then
        CAND=${REF#"${R}"/}
        if git show-ref --verify --quiet "refs/heads/$CAND"; then
          SWITCH_NAME="$CAND"
          break
        fi
      fi
    done
    git switch "$SWITCH_NAME"
    ;;
  branch)
    git switch "$REF"
    ;;
  *)
    git switch "$REF"
    ;;
esac

exit 0
