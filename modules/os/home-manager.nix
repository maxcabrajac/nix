{ inputs, ... }: {
	os.base = {
		imports = [ inputs.home-manager.nixosModules.home-manager ];
		home-manager = {
			extraSpecialArgs = { inherit inputs; };
			useGlobalPkgs = true;
		};
	};
}
