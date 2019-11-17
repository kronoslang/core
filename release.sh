#! /bin/bash

set -e

if [ -n "$(hg st)" ]; then
	>&2 echo "Please clean hg status first!"
	exit 1
fi

ver="^[0-9]+\.[0-9]+\.[0-9]+$"

if [[ ! $1 =~ $ver ]]; then
	>&2 echo "$1 is not a valid version number"
	exit 2
fi

set -x

hg tag $1 --user "$(whoami)"
git add -A
git commit -m "Release $1"
git tag $1 && git push --tags


