{ lib, config, ... }: {
	options.profiles = lib.genAttrs [
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
