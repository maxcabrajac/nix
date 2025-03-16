{ lib, pkgs, config, ... }: let
	enable = { enable = true; };
	disable = { enable = false; };
in {

	programs = {
		lf = enable;
		abcd = enable;
	};

	home = {
		packages = with pkgs; [
			neovim
		];
	};
}
