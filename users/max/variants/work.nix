{ lib, config, pkgs, ... }: let
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

		home = {
			packages = [
				pkgs.terraform
				pkgs.kubernetes-helm
				pkgs.awscli
			];

			shellAliases.ghi = "ggh inloco";
			sessionPath = [ "$HOME/.local/bin" ];
		};
	};
}
