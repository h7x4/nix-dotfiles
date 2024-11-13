if [ -n "${1:-}" ]; then
  TARGET_COMMIT="$1"
  shift
else
  TARGET_COMMIT="HEAD"
fi

COMMIT_MESSAGE=$(git log -1 --pretty=format:'%s' "$TARGET_COMMIT")

if [[ $COMMIT_MESSAGE =~ ^fixup!* ]]; then
  git commit -m "$COMMIT_MESSAGE" "$@"
else
  git commit --fixup "$TARGET_COMMIT" "$@"
fi
