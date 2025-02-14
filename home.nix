{ lib, pkgs, ... }: let
	username = "max";
	hypr = import ./hypr.nix { inherit lib pkgs; };
in {
	home = {
		packages = with pkgs; [
			hypr.package
			home-manager
			eww
		];

		inherit username;
		homeDirectory = "/home/${username}";

		# "NEVER CHANGE THIS"
		stateVersion = "24.11";
	};
}
