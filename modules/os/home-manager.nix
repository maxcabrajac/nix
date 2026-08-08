{ inputs, util, ... }: {
	os.base = {
		imports = [ inputs.home-manager.nixosModules.home-manager ];
		home-manager = {
			extraSpecialArgs = { inherit util inputs; };
			useGlobalPkgs = true;
		};
	};
}
