{ lib, ... }: {
	networking.useDHCP = lib.mkDefault true;
	services.resolved = {
		enable = true;
		settings.Resolve = {
			DNSOverTLS = "opportunistic";
			DNSSEC = "allow-downgrade";
		};
	};
}
