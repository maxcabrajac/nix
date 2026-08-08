{ pkgs, config, lib, ... }: lib.mkIf config.profiles.social {
	programs = {
		discord.enable = true;
	};

	home.packages = with pkgs; [
		telegram-desktop
	];
}
