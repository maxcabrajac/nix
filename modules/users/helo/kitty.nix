{
	user.helo = { pkgs, config, ... }: {
		terminal.package = pkgs.kitty;
		global.keybinds = {
			M-Return = {
				pkg = config.terminal.package;
				description = "Open a new terminal (${config.terminal.package.name})";
			};
		};
	};
}
