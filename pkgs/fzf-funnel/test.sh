#! /usr/bin/env bash
read -r -d '' input <<EOF
on_all_three@0
on_all_three@1
on_all_three
without_zero@1
without_zero
without_suffix
only_on_one@1
many_matches_a_lil_worse
many_matches_best
many_matches_much_mush_much_worse
EOF

filters=("@0" "@1")

declare -A ok_cases=(
	[on_all_three]="@0"
	[without_zero]="@1"
	[without_suffix]=""
	[only_on_one]="@1"
	[many_matches]="_best"
)

for selector in "${!ok_cases[@]}"; do
	suffix="${ok_cases[$selector]}"
	expected="${selector}${suffix}"
	got="$(./main.sh "${filters[@]}" -- "$selector" <<< "$input")"
	if [ "$expected" != "$got" ]; then
		echo "X $selector: Expected $expected got $got"
	else
		echo "O"
	fi
done

selector="does_not_exist"
output="$(./main.sh "${filters[@]}" -- "$selector" <<< "$input")"
got="$?"
if [ $got -eq 1 ]; then
	echo "O"
else
	echo "X $selector: Expected exit code 1. Got $got with output $output"
fi

# TODO: test selectorless flow
# ./main.sh "${filters[@]}" -- <<< "$input"
# should open fzf and wait for input
