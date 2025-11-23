{ lib, config, ... }: {
	options.profiles = lib.genAttrs [
		"gui"
		"games"
	] (name: lib.mkEnableOption name);

	config = {
		global.keybinds = [
			{
				mods = "M";
				key = "Return";
				pkg = config.terminal.package;
				description = "Open a new terminal (${config.terminal.package.name})";
			}
		];
	};
}
