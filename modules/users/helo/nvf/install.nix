{ inputs, config, ... }: {
	user.helo = {
		imports = [ inputs.nvf.homeManagerModules.nvf ];
		programs.nvf = {
			enable = true;
			defaultEditor = true;
			settings.imports = [ config.nvf.helo ];
		};
	};
}
