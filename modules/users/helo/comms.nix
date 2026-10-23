{
	user.helo = { pkgs, ... }: {
		programs.discord.enable = true;
		home.packages = with pkgs; [
			telegram-desktop
			element-desktop
		];
	};
}
