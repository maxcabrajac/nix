{ pkgs, config, lib, ... }: lib.mkIf config.profiles.social {
	home.packages = with pkgs; [
		telegram-desktop
		element-desktop
		discord
	];
}
