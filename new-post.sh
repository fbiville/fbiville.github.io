#!/bin/bash
set -Eeuxo pipefail



main() {
	if [ $# != 1 ]; then
		usage
		exit 42
	fi
	if [ -z $1 ]; then
		usage
		exit 242
	fi

	title=${1}
	sanitized_title=`echo $title | tr -s ' !?,#@' '_'`
	time=`date +%Y-%m-%d`
	file="_posts/${time}-${sanitized_title}.md"
	metadata "${title}" > $file
}

metadata() {
	cat <<META
---
layout: post
title: "${1}"
---
META
}

usage() {
    cat <<HELP_USAGE

    $(basename $0) <title>
HELP_USAGE
}

main "$@"