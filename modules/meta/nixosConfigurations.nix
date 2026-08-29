{ config, lib, inputs, ... }: {
	config.flake.nixosConfigurations =
		config.host
		|> lib.mapAttrs (_: module: inputs.nixpkgs.lib.nixosSystem {
			modules = [
				module
			];
		})
	;
}
