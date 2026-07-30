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
		home.stateVersion = "25.05"; # Did you read the comment?
	};
}
