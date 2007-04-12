#!/bin/bash

# Usage:
#  $1 Trac URL
#  $2 Path to Trac installation

set -e

URL="$1"
tracpath="$2"

CMD="$(dirname $(readlink -f $0))/trac-post-commit-hook"

hg log -r $HG_NODE --template '{node|short}\n{author}\n{desc}\n' | {
  read shortnode
  read user
  read desc
  while read line
  do
    desc="$desc"$'\n'"$line"
  done

  "$CMD" -p "$tracpath" -r "$shortnode" -u "$user" -s "$URL" -m "$desc"
}
