{ lib, ... }: {
	host.hllzr = { pkgs, ... }: let
		bins = pkgs |> lib.mapAttrs (_: lib.getExe);
	in {
		environment.systemPackages = lib.singleton <| pkgs.writeShellScriptBin "update" ''
			OP=""
			BRANCH=""
			NH_FLAGS=""
			NIX_FLAGS="--accept-flake-config --refresh"

			while [[ $# -gt 0 ]]; do
				case $1 in
					-b|--branch)
						BRANCH="/$2"
						shift 2
					;;
					--nix-flag)
						NIX_FLAGS="$NIX_FLAGS $2"
						shift 2
					;;
					--nh-flag)
						NH_FLAGS="$NH_FLAGS $2"
						shift 2
					;;
					build|boot|switch)
						OP=$1
						shift
					;;
				esac
			done

			if [[ -z "$OP" ]]; then
				echo No operation selected.
				exit 1
			fi

			${bins.nh} os $OP $NH_FLAGS github:maxcabrajac/nix''${BRANCH}#hllzr -- $NIX_FLAGS
		'';
	};

}
