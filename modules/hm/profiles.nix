{ lib, config, ... }: {
	options.profiles = lib.genAttrs [
		"gui"
	] (name: lib.mkEnableOption name);
}
