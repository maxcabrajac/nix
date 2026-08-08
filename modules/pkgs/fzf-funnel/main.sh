#! /usr/bin/env bash

args=("${@}")

sep_ind=-1
for i in "${!args[@]}"; do
    if [[ ${args[i]} == "--" ]]; then
        sep_ind=$i
        break
    fi
done

case "$sep_ind" in
	"-1")
		# Not found
		filters=()
		selector="${args[*]}"
		;;
	"$((${#args[@]}-1))")
		# Is last
		exec fzf
		;;
	*)
		filters=("${args[@]:0:sep_ind}")
		after=("${args[@]:sep_ind+1}")
		selector="${after[*]}"
		;;
esac

input="$(< /dev/stdin)"

function query() {
	local out exit_code

	out="$(fzf --filter="$selector")"
	exit_code=$?
	# output if non-empty
	[[ -n "$out" ]] && echo "$out" | head -n1
	return $exit_code
}


for f in "${filters[@]}"; do
	echo "$input" | grep "$f" | query && exit 0
done

echo "$input" | query
