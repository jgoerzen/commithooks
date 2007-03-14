#!/bin/bash

# Usage:
#  $1 Trac URL
#  $2 Path to Trac installation

set -e

URL="$1"
tracpath="$2"

CMD="$(dirname $(readlink -f $0))/trac-post-commit-hook"

"$CMD" \
    -p "$tracpath" \
    -r "$HG_NODE" \
    -u "`hg log -r $HG_NODE | grep '^user:' | sed 's/^user: *//'`" \
    -s "$URL" \
    -m "`hg log -v -r $HG_NODE | sed '1,/^description:/ d'`"

rm "$FILE"
