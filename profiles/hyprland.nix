{ lib, pkgs, config, ... }: let
	enable = { enable = true; };
	disable = { enable = false; };
in {

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
}
