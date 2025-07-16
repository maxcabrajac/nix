{
	isNixOs = false;
	module = { config, lib, pkgs, ... }: {
		nixpkgs.config.allowUnfree = true;
		nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

		nix.settings.experimental-features = [ "nix-command" "flakes" "pipe-operators" ];

		# Use the systemd-boot EFI boot loader.
		home-manager.users.max = {
			programs.fish.enable = true;
			home.stateVersion = "25.05"; # Did you read the comment?
		};

		users.users.max = {
			isNormalUser = true;
		};

		# For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
		system.stateVersion = "25.05"; # Did you read the comment?
	};
}
