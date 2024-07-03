set -euo pipefail

HOUR_SHIFT="$1"
shift

if [[ $HOUR_SHIFT == -* ]]; then
  HOUR_SHIFT="${HOUR_SHIFT#*-}"
  OPERATOR="-"
else
  OPERATOR="+"
fi

DATE=$(date -d "now ${OPERATOR} ${HOUR_SHIFT} hours")

while true; do
  echo "Commiting with date: ${DATE} (${OPERATOR}${HOUR_SHIFT}h)"
  read -rp "Do you want to proceed? (y/n) " yn

  case $yn in
    [yY] )
      break;;
    [nN] )
      exit;;
    * ) echo invalid response;;
  esac
done

export GIT_COMMITTER_DATE="${DATE}"
export GIT_AUTHOR_DATE="${DATE}"

git commit "$@"
