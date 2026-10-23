{
	user.helo = { pkgs, ... }: {
		programs.firefox.enable = true;
		home.packages = with pkgs; [
			kitty
			lf
			neovim
			nh
			pavucontrol
		];
	};
}
