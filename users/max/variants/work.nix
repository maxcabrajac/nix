{ lib, config, ... }: let
	variantName = "work";
in {
	options.variant = lib.mkOption {
		type = lib.types.enum [ variantName ];
	};

	config = lib.mkIf (config.variant == variantName) {
		programs.fish.enable = true;
		home.shellAliases.ghi = "ggh inloco";
		home.sessionPath = [ "$HOME/.local/bin" ];
		targets.genericLinux.enable = true;
	};
}
