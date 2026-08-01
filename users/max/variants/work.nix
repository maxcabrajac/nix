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
		programs.awscli = enable // {
			aws_profile.filters = [
				"sre-1"
				"sre-0"
			];
		};

		home = {
			packages = with pkgs; [
				kubernetes-helm
				telegram-desktop
				terraform
			];

			shellAliases.ghi = "ggh inloco";
			sessionPath = [ "$HOME/.local/bin" ];
		};
	};
}
