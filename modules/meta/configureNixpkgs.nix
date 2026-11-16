{ lib, inputs, withSystem, config, ... }: {
	perSystem = { system, ... }: {
		_module.args.pkgs = import inputs.nixpkgs {
			inherit system;
			config.allowUnfree = true;
			overlays =
				config.flake.overlays
				|> lib.attrValues
			;
		};
	};

	os.base = { config, ... }: {
		nixpkgs.pkgs = withSystem config.nixpkgs.hostPlatform.system ({ pkgs, ... }: pkgs);
	};
}
