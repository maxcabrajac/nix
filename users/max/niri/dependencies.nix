{ config, lib, pkgs, ... }: lib.mkIf config.programs.niri.enable {
	global.keybinds = {
		M-Space.pkg = pkgs.fuzzel;
	};
	programs = {
		walker.enable = true;
		lf.useAsXdgPortalOn.niri = true;
	};
	services = {
		playerctld.enable = true;
		wlsunset.enable = true;
	};
}
