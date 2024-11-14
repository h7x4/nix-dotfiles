if [ -n "${1:-}" ]; then
  TARGET_BRANCH="$1"
  shift
else
  TARGET_BRANCH=$(git remote show origin | sed -n '/HEAD branch/s/.*: //p')
fi

FORK_POINT=$(git merge-base --fork-point "$TARGET_BRANCH")

COMMITS_SINCE_FORK_POINT=$(git log --format=format:'%s' "$FORK_POINT"..HEAD | grep -v -E '^fixup!')

RESULT=$(fzf <<<"$COMMITS_SINCE_FORK_POINT")

if [ "$RESULT" == "" ]; then
  echo "Doing nothing..."
else
  git commit -m "fixup! $RESULT" "$@"
fi
