#! /bin/bash

# usage:
# $1 mail address

# Originally written by Andres Loeh
# Changed by Duncan Coutts to send an email per-patch rather than per-push
# Modified by John Goerzen to use trac-post-commit-hook

#email=$1

INSTDIR="$(dirname $(readlink -f $0))"

[[ -z ${DARCS} ]] && DARCS="/usr/bin/darcs"
[[ -z ${CURRENTHASH} ]] && CURRENTHASH="_darcs/current-hash"

hash=$(cat ${CURRENTHASH})

# find all the patches since the one identified by the current hash
patches=$(${DARCS} changes		\
	--reverse			\
	--from-match="hash ${hash}"	\
	--match="not hash ${hash}"	\
	--xml-output			\
	| grep "hash='"			\
	| sed "s/^.*hash='\([^']*\)'.*$/\1/")

# update the current hash to the last hash we've seen.
patch=${patches##*[${IFS}[:cntrl:]]}
if [[ -n ${patch} ]]; then
	echo ${patch} > ${CURRENTHASH}
fi

# Send the emails asynchronously so we don't hold up the apply process
# This also allows the sending of the emails to take it's time and do
# them in the proper chronological order.
#(
	# send an email for each patch
	for patch in ${patches}; do
	
	        # sleep for at least a second otherwise all the emails sent can have
		# the same timestamp and we loose the order of the patches.
		sleep 1.1
		
		patchname=$(${DARCS} changes		\
			--matches="hash ${patch}"	\
			--xml-output			\
			| grep '<name>'			\
			| sed 's|.*<name>\(.*\)</name>.*|\1|')

                author=$(${DARCS} changes               \
                        --matches="hash ${patch}"       \
                        --quiet                         \
                        | grep '^[A-Z]'                 \
                        | sed 's/^.* //'           )

                rev=$(${DARCS} changes                  \
                       --to-match="hash ${patch}"       \
                       --quiet                          \
                       | grep '^[A-Z]'                  \
                       | wc -l                     )

                echo "Scanning rev ${rev} for ticket tags..."

                project=$(basename $(pwd))

                log=$(${DARCS} changes                  \
                       --matches="hash ${patch}"        )

                "$INSTDIR/trac-post-commit-hook"    \
                       -p "/home/trac/instances/${project}" \
                       -r "${rev}" \
                       -u "${author}" \
                       -s "http://software.complete.org/${project}" \
                       -m "${log}" \
                       || true

                DCTMP="`mktemp -t darcs-commit-messages-split.sh.XXXXXXXXXX`"
                darcs changes --matches="hash ${patch}" > "$DCTMP"
                "$INSTDIR/deb-post-commit-hook" \
                       -r "${rev}" \
                       -u "${author}" \
                       -m "${log}" \
                       -s "bugs.debian.org" \
                       -U "http://software.complete.org/${project}/changeset/${rev}" \
                       -f "$DCTMP" \
                       -F "jgoerzen@complete.org"

		
	done
#) &

exit 0

