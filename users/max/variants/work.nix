{ lib, config, ... }: let
	variantName = "work";
	enable = { enable = true; };
in {
	options.variant = lib.mkOption {
		type = lib.types.enum [ variantName ];
	};

	config = lib.mkIf (config.variant == variantName) {
		programs.fish = enable;
		terminal = enable;
		targets.genericLinux = enable;

		home.shellAliases.ghi = "ggh inloco";
		home.sessionPath = [ "$HOME/.local/bin" ];
	};
}
