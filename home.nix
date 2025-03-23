args@{ lib, pkgs, helpers, ... }: let
	username = builtins.getEnv "USER";
	hostname = builtins.getEnv "HOST";
in {
	imports = [
		(./. + "/hosts/${hostname}.nix")
	];

	home = {
		packages = [
			pkgs.home-manager
			pkgs.getField
		];

		inherit username;
		homeDirectory = "/home/${username}";

		# "NEVER CHANGE THIS"
		stateVersion = "24.11";
	};
}
