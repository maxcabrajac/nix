{ lib, config, pkgs, ... }: let
	variantName = "work";
	enable = { enable = true; };
in {
	options.variant = lib.mkOption {
		type = lib.types.enum [ variantName ];
	};

	config = lib.mkIf (config.variant == variantName) {
		targets.genericLinux = enable;
		terminal = enable;
		programs = {
			fish = enable;
			awscli = enable // {
				aws_profile.filters = [
					"sre-1"
					"sre-0"
				];
			};
			kubectl = enable;
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
