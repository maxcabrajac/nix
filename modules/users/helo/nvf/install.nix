{ inputs, config, ... }: {
	user.helo = {
		imports = [ inputs.nvf.homeModules.nvf ];
		programs.nvf = {
			enable = true;
			defaultEditor = true;
			settings.imports = [ config.nvf.helo ];
		};
	};
}
