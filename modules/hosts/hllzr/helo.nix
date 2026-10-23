{ config, ... }: {
	host.hllzr.humans.hellohelo = {
		os = {
			extraGroups = [
				"wheel"
				"docker"
				"dialout"
			];
		};
		hm.imports = [ config.user.helo ];
	};
}

