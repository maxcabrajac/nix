{ config, lib, pkgs, ... }: {
	hmExport.niriEnabled = {
		from = [ "programs" "niri" "enable" ];
	};

	programs.niri = {
		enable = config.hmExported.niriEnabled;
		useNautilus = false;
	};

	environment.systemPackages = lib.optional config.programs.niri.enable pkgs.xwayland-satellite;
}
