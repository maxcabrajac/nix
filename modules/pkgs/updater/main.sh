#! /usr/bin/env bash

set -e

append() {
	local -n target_var="$1"
	shift
	target_var="$target_var $*"
}

OP=""
FLAKE=""
BRANCH=""
NH_FLAGS="--accept-flake-config --refresh --bypass-root-check"
NIX_FLAGS=""
CONFIRM="true"

while [[ $# -gt 0 ]]; do
	ARG="$1"
	shift
	case "$ARG" in
		--flake)
			FLAKE="$1"
			shift
		;;
		-b|--branch)
			BRANCH="/$1"
			shift
		;;
		--nix-flag)
			append NIX_FLAGS "$1"
			shift
		;;
		--nh-flag)
			append NH_FLAGS "$1"
			shift
		;;
		--yes)
			CONFIRM="false"
		;;
		build|boot|switch)
			OP="$ARG"
		;;

		# Profiles
		--slow)
			append NH_FLAGS --cores 1 --max-jobs 1
		;;
		--no-pretty)
			append NH_FLAGS --no-nom
		;;

		*)
			echo "Unknown arg: $ARG"
			exit 1
		;;
	esac
done

if [[ -z "$OP" ]]; then
	echo No operation selected.
	exit 1
fi

if [[ "$OP" != "build" ]]; then
	OUT_DIR=$(mktemp -d)
	trap 'rm -rf $OUT_DIR' EXIT
	OUT="$OUT_DIR/out"
	append NH_FLAGS --out-link "$OUT"
fi

# shellcheck disable=SC2086
nh os build $NH_FLAGS "${FLAKE}${BRANCH}" -- $NIX_FLAGS
[[ "$OP" == "build" ]] && exit 0

if "$CONFIRM"; then
	read -p "Apply? (y) " -n 1 -r
	if ! [[ "$REPLY" =~ ^[Yy]?$ ]]; then
		echo "Cancelled"
		exit 1
	fi
fi

STC=$OUT/bin/switch-to-configuration

sudo "$STC" boot
[[ "$OP" == "boot" ]] && exit 0

sudo "$STC" test
