{ pkgs, config, lib, inputs, ... }: lib.mkIf config.profiles.social {
	programs = {
		discord = {
			enable = true;
			package = pkgs.altPkgs.discordPatch.discord;
		};
	};

	home.packages = with pkgs; [
		telegram-desktop
	];
}
