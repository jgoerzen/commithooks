#!/bin/bash

set -e

URL="$1"
FROMADDR="$2"

CMD="$(dirname $(readlink -f $0))/deb-post-commit-hook"

FILE="`mktemp -t hg-commit.sh.XXXXXXXXXX`"

cat >"$FILE" <<EOF
  Download raw diff from:
    $URL/raw-rev/$HG_NODE

EOF

hg log -v -r "$HG_NODE" | grep -v "^files:" >> "$FILE"

"$CMD" -r "$HG_NODE" \
    -u "`hg log -r $HG_NODE | grep '^user:' | sed 's/^user: *//'`" \
    -m "`hg log -v -r $HG_NODE | sed '1,/^description:/ d'`" \
    -s "bugs.debian.org" \
    -U "$URL?cmd=changeset;node=$HG_NODE;style=gitweb" \
    -f "$FILE" \
    -F "$2"

rm "$FILE"
