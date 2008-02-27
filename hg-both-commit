#!/bin/bash

# Usage:
#   $1 Trac URL
#   $2 Path to Trac installation
#   $3 URL for Mercurial web server for this repo
#   $4 From address for Debian BTS

BASE="$(dirname $(readlink -f $0))"

"$BASE/hg-trac-commit.sh" "$1" "$2"
"$BASE/hg-deb-commit.sh" "$3" "$4"

