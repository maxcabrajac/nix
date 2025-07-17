{ lib, ... }: {
	nixpkgs.config.allowUnfree = true;
	nix.settings.experimental-features = [ "nix-command" "flakes" "pipe-operators" ];
	networking.useDHCP = lib.mkDefault true;
}
