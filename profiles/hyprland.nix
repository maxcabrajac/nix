{ lib, pkgs, config, ... }: let
	enable = { enable = true; };
	disable = { enable = false; };
in {
	options.profile.hyprland = lib.mkEnableOption "Hyprland Profile";

	config = lib.mkIf config.profile.hyprland {
		programs = {
			bemenu = enable;
			hypr = enable;
			zathura = enable;
			dmenu_scripts = enable;
		};

		home = {
			packages = with pkgs; [
				eww
			];
		};
	};
}
