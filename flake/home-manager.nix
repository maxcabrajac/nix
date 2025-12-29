{ inputs, util, config, lib, ... }: {
	flake.nixosModules = {
		inherit (inputs.home-manager.nixosModules) home-manager;
		home-manager-inject-args = {
			home-manager = {
				extraSpecialArgs = { inherit util inputs; };
				sharedModules = config.flake.homeModules |> lib.attrValues;
				useGlobalPkgs = true;
			};
		};
	};
}
