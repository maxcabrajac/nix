{ pkgs, ... }: {
	home.packages = with pkgs; [
		fira-code
		fira-code-symbols
		nerd-fonts.fira-code
	];
	fonts.fontconfig.enable = true;
}
