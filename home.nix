args@{ lib, pkgs, helpers, ... }: let
	username = builtins.getEnv "USER";
	hostname = builtins.getEnv "HOST";
in {
	imports = [
		(./. + "/hosts/${hostname}.nix")
	];

	home = {
		inherit username;
		homeDirectory = "/home/${username}";

		# "NEVER CHANGE THIS"
		stateVersion = "24.11";
	};
}
