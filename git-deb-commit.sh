#!/bin/bash

# Usage:
#
#  $1 Path to gitweb web server for this repo
#     
#     Should end with '?' if pathinfo is used or ';' otherwise
#
#     Examples:
#     
#     http://git.kernel.org/gitweb.cgi?p=boot/syslinux/syslinux-gpxe.git;
#     http://repo.or.cz/w/git.git?
#
#     After this, we can append things like "a=shortlog"
#
#  $2 From address for mails to Debian BTS
set -e

URL="$1"
FROMADDR="$2"

CMD="$(dirname $(readlink -f $0))/deb-post-commit-hook"

FILE="`mktemp -t git-commit.sh.XXXXXXXXXX`"

while read gitrev; do

git show -s --pretty "$gitrev" > "$FILE"
cat >>"$FILE" <<EOF

Diff: ${URL}a=commitdiff_plain;h=${gitrev}"

EOF

git diff-tree --stat --summary --find-copies-harder \
    "${gitrev}^..${gitrev}" >> "$FILE"


"$CMD" -r "$HG_NODE" \
    -u "`git show -s --pretty=format:%an ${gitrev}`" \
    -m "`git show -s --pretty=format:%s%n%b ${gitrev}`" \
    -s "bugs.debian.org" \
    -U "${URL}a=commit;h=${gitrev}" \
    -f "$FILE" \
    -F "$2"

rm "$FILE"
