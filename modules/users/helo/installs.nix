{
	user.helo = { pkgs, ... }: {
		programs.firefox.enable = true;
		home.packages = with pkgs; [
			kitty
			lf
			nh
			pavucontrol
		];
	};
}
