#! /usr/bin/env bash

set -e

append() {
	local -n target_var="$1"
	shift
	target_var="$target_var $*"
}

log_on_failure() {
	local output
	local exit_code
	output="$("$@" 2>&1)"
	exit_code="$?"

	if [ "$exit_code" -ne 0 ]; then
		echo "Failed while running: $*" >&2
		echo "Output:" >&2
		echo "$output" >&2
		return $exit_code
	fi
}

OP=""
FLAKE=""
BRANCH=""
NH_FLAGS="--accept-flake-config --refresh --bypass-root-check"
NIX_FLAGS=""
CONFIRM="true"
BUILD_WRAPPER=""
RECREATE_BOOT_ENTRY="true"

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
			BUILD_WRAPPER="nice -n100"
		;;
		--no-pretty)
			append NH_FLAGS --no-nom
		;;
		--no-recreate-entry)
			RECREATE_BOOT_ENTRY=false
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
$BUILD_WRAPPER nh os build $NH_FLAGS "${FLAKE}${BRANCH}" -- $NIX_FLAGS
[[ "$OP" == "build" ]] && exit 0

if "$CONFIRM"; then
	read -p "Apply? (y) " -n 1 -r
	if ! [[ "$REPLY" =~ ^[Yy]?$ ]]; then
		echo "Cancelled"
		exit 1
	fi
fi

REAL_OUT=$(readlink "$OUT")
if "$RECREATE_BOOT_ENTRY" || ! grep -q "$REAL_OUT" <(readlink /nix/var/nix/profiles/system-*-link); then
	echo "Writting boot entry..."
	log_on_failure sudo systemd-inhibit \
		--what=sleep:shutdown \
		--who="System Upgrader" \
		--why="Writting boot options" \
		nixos-rebuild boot --store-path "$REAL_OUT"
else
	echo "Skipped writting boot entry"
fi
[[ "$OP" == "boot" ]] && exit 0

echo "Activating..."
log_on_failure sudo nixos-rebuild test --store-path "$REAL_OUT"
