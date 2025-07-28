#
# The variables $engines and $default_engine are injected into this script by nix
#
#??[runtimeInputs]
#??pkgs = [ "jq", "gnused", "coreutils" ]
#??END

# enable extended globing (better builtin "regex")
shopt -s extglob

jq() {
	command jq --compact-output --raw-output "$@"
}

url_encode() {
	echo -n "$@" | od -t x1 -An | tr ' ' '%' | tr -d '\n'
}

all_aliases() {
	echo $engines | jq keys[]
}

user_input="$(all_aliases | $DMENU -p search)"

if [ "$user_input" = "" ]; then
	exit 0
fi

maybe_alias="$(echo $user_input | cut -d' ' -f 1)"

maybe_site="$(echo $engines | jq .$maybe_alias)"

if [ "$maybe_site" != "null" ]; then
	alias=$maybe_alias
	site=$maybe_site

	query=${user_input##$alias*( )}
	search_engine=$(echo $site | jq .search_engine)

	if [ "$search_engine" = "null" ]; then
		echo $(echo $site | jq .name) is not a valid search engine, falling back to bookmark >&2
		query=""
	fi

	if [ "$query" = "" ]; then
		echo $site | jq .bookmark
		exit 0
	fi
else
	search_engine=$default_engine
	query=$user_input
fi

echo -n $search_engine | sed "s/%%/$(url_encode "$query")/"
