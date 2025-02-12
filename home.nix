{ lib, pkgs, ... }:
{
	home = {
		packages = with pkgs; [
			hello
		];

		username = "max";
		homeDirectory = "/home/max";

		# "NEVER CHANGE THIS"
		stateVersion = "24.11";
	};
}
