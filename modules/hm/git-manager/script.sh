#! /bin/bash

root="${root:-${XDG_DATA_HOME:-$HOME/.local/share}/git-manager}"
cloner="${cloner:-echo}"

host="$1"
shift

repo="$1"
shift
for part in "$@"; do
	repo="$repo/$part"
done

# Sanitize url
url="$host/$repo"
case "$host" in
	github) url="git@github.com:$repo" ;;
esac

target="$root/$(echo "$host" | tr '/' '-')/$repo"

if ! [ -d "$target" ]; then
	$cloner "$url" "$target"
fi

echo "$target"
