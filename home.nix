args@{ lib, pkgs, ... }: let
	username = "max";
in {
	home = {
		packages = with pkgs; [
			home-manager
			neovim
		];

		inherit username;
		homeDirectory = "/home/${username}";

		# "NEVER CHANGE THIS"
		stateVersion = "24.11";
	};

}
