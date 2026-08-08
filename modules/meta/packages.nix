{ lib, config, ... }: {
	options = {
		packages = lib.mkOption {
			type = with lib.types; attrsOf <| functionTo package;
		};
	};

	config = {
		flake.overlays.packages = pkgs: _:
			config.packages
			|> lib.mapAttrs (_: drv: pkgs.callPackage drv {})
		;

		perSystem = { pkgs, ... }: {
			packages = lib.fix (final:
				config.flake.overlays.packages (lib.recursiveUpdate pkgs final) pkgs
			);
		};
	};
}
