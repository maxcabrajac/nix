{ lib, config, ... }: {
	options.profiles = lib.genAttrs [
		"games"
	] (name: lib.mkEnableOption name);

	config = {
		global.keybinds = {
			M-Return = {
				pkg = config.terminal.package;
				description = "Open a new terminal (${config.terminal.package.name})";
			};
		};
	};
}
