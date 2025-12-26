{ lib, ... }: {
	networking.useDHCP = lib.mkDefault true;
	services.resolved = {
		enable = true;
		dnsovertls = "opportunistic";
		dnssec = "allow-downgrade";
	};
}
