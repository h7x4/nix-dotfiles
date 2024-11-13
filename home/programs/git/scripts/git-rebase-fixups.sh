if [ -n "${1:-}" ]; then
  TARGET_BRANCH="$1"
  shift
else
  TARGET_BRANCH=$(git remote show origin | sed -n '/HEAD branch/s/.*: //p')
fi

FORK_POINT=$(git merge-base --fork-point "$TARGET_BRANCH")

git rebase "$FORK_POINT" --autosquash "$@"
