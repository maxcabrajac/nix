{ inputs, lib, config, ... }: {
	options = {
		altPkgs = lib.mkOption {
			type = with lib.types; attrsOf anything;
			default = {};
		};
	};

	config = {
		flake.overlays.altPkgs = pkgs: _: {
			altPkgs = config.altPkgs |> lib.mapAttrs (_: nixpkgs:
				import nixpkgs {
					inherit (pkgs.stdenv.hostPlatform) system;
					inherit (pkgs) config;
				}
			);
		};
	};
}
