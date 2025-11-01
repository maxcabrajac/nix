{ lib, ... }: {
	options.profiles = lib.genAttrs [
		"gui"
		"games"
	] (name: lib.mkEnableOption name);
}
