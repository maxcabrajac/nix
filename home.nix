args@{ lib, pkgs, helpers, ... }: let
	username = "max";
in {
	imports = [
		./profiles/hyprland.nix
		./profiles/terminal.nix
	];

	home = {
		packages = helpers.all;

		inherit username;
		homeDirectory = "/home/${username}";

		# "NEVER CHANGE THIS"
		stateVersion = "24.11";
	};


	nixGL = {
		packages = pkgs.nixgl;
		defaultWrapper = "mesa";
		offloadWrapper = "mesa";
	};
}
