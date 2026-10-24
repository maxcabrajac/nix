{ lib, ... }: {
	host.hllzr = { pkgs, ... }: let
		bins = pkgs |> lib.mapAttrs (_: lib.getExe);
	in {
		environment.systemPackages = lib.singleton <| pkgs.writeShellScriptBin "update" ''
			${bins.nh} os ''${1} github:maxcabrajac/nix''${2}#hllzr -- --accept-flake-config --refresh
		'';
	};

}
