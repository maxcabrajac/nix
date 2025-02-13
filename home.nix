{ lib, pkgs, ... }: let
	username = "max";
in {
	home = {
		packages = with pkgs; [
			hyprland
			nixgl.auto.nixGLDefault
		];

		inherit username;
		homeDirectory = "/home/${username}";

		# "NEVER CHANGE THIS"
		stateVersion = "24.11";
	};
}
