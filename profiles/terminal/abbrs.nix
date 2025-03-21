{ lib, config, ... }: {
	options = {
		home.shellAbbrs = lib.mkOption {
			type = lib.types.attrsOf lib.types.singleLineStr;
			default = {};
		};
	};

	config.programs = let abbrs = config.home.shellAbbrs; in {
		fish.shellAbbrs = abbrs;
		bash.shellAliases = abbrs;
		zsh.shellAliases = abbrs;
	};
}
