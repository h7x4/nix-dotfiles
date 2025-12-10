set -euo pipefail

if [ -n "${1:-}" ]; then
  REF="${1}"
else
  REF="HEAD"
fi

# TODO: optionally keep track of which files the authors were present in,
#       and print a list of up to N files where the authors contributed the most.

git ls-tree -r "${REF}" \
| while read -r _filemode _objtype _githash filepath; do
  git blame --line-porcelain "${filepath}"
done \
| grep --binary-files=without-match '^author ' \
| sed -e 's/author //' \
| awk '{ a[$0]+=1 } END{ for (i in a) { print a[i],i } }' \
| sort --numeric-sort --key 1 --reverse
