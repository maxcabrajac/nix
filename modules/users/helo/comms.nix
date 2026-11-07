{
	user.helo = { pkgs, ... }: {
		home.packages = with pkgs; [
			discord
			telegram-desktop
			element-desktop
		];
	};
}
