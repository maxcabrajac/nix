{ config, ... }: {
	host.nixos.humans.max = {
		os = {
			extraGroups = [
				"wheel"
				"docker"
				"dialout"
			];
		};
		hm = {
			imports = [ config.user."max#home" ];
			profiles = {
				gui = true;
				games = true;
				social = true;
			};
			programs.fish.enable = true;
		};
	};
}

