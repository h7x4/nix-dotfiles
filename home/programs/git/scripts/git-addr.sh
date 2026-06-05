GIT_ROOT_DIR="$(git rev-parse --show-toplevel)"

if [ "$GIT_ROOT_DIR" = "" ]; then
  echo "Not a git repository"
  exit 1
fi

# Transform all file args to prepend the git root dir
declare -a FINAL_ARGS

for i in "$@"; do
  if [ -f "$GIT_ROOT_DIR/$i" ]; then
    FINAL_ARGS+=("$GIT_ROOT_DIR/$i")
  else
    FINAL_ARGS+=("$i")
  fi
done

exec git add "${FINAL_ARGS[@]}"
