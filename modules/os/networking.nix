{ lib, ... }: {
	os.base = {
		networking.useDHCP = lib.mkDefault true;
		services.resolved = {
			enable = lib.mkDefault true;
			settings.Resolve = lib.mkDefault {
				DNSOverTLS = "opportunistic";
				DNSSEC = "allow-downgrade";
			};
		};
	};
}
