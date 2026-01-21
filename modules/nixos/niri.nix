{ config, lib, pkgs, ... }: let
	niriEnabled = config.lib.humans.hmConfigs
		|> map (hm: hm.programs.niri.enable)
		|> lib.any (x: x)
	 ;
in {
	programs.niri = {
		enable = niriEnabled;
		useNautilus = false;
	};

	environment.systemPackages = lib.optional config.programs.niri.enable pkgs.xwayland-satellite;
}
