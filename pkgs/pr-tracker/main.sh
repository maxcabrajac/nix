#! /usr/bin/env bash

: "${XDG_DATA_HOME:=$HOME/.local/share}"
: "${PR_TRACKER_DATA_FILE:=$XDG_DATA_HOME/pr_tracker_data.json}"

touch "$PR_TRACKER_DATA_FILE"

main() {
	CMD=list
	if [ $# -ne 0 ]; then
		CMD=$1
		shift
	fi

	case $CMD in
		add)
			REPO=$1
			shift
			NUM=$1
			shift
			DESC="$@"

			main remove "$REPO" "$NUM"
			jq -nc --arg repo "$REPO" --arg num "$NUM" --arg desc "$DESC" '
				{
					repo: $repo,
					num: $num,
					desc: $desc,
				}
			' >> "$PR_TRACKER_DATA_FILE"
		;;
		list)
			mapfile -t lines < "$PR_TRACKER_DATA_FILE"
			for line in "${lines[@]}"; do
				REPO="$(jq -r '.repo' <<< "$line")"
				NUM="$(jq -r '.num' <<< "$line")"
				DESC="$(jq -r '.desc' <<< "$line")"

				printf '%s\x01%s#%s\x01' "$DESC" "$REPO" "$NUM"
				gh_out="$(gh pr view -R "$REPO" "$NUM" --json state,updatedAt --template "{{timeago .updatedAt}}"$'\x01'"{{.state}}" 2> /dev/null)"
				if [ $? -ne 0 ]; then
					gh_out=$'\x01'"FAILED"
				fi
				echo "$gh_out"
			done \
				| column \
				--input-separator $'\x01' \
				--table \
				--table-column "name=desc,wrap" \
				--table-column "name=pull request" \
				--table-column "name=last update,right" \
				--table-column "name=state"
		;;
		remove)
			REPO=$1
			shift
			NUM=$1
			shift

			cat "$PR_TRACKER_DATA_FILE" | jq -c --arg repo "$REPO" --arg num "$NUM" '
				select(.repo == $repo and .num == $num | not)
			' | sponge "$PR_TRACKER_DATA_FILE"
		;;
		*)
			echo "Unknown command: $CMD"
		;;
	esac
}

main "$@"
