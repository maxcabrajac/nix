{ config, lib, pkgs, ... }: lib.mkIf config.programs.niri.enable {
	global.keybinds = {
		M-Space.pkg = pkgs.fuzzel;
	};
	programs.lf.useAsXdgPortalOn.niri = true;
	services.playerctld.enable = true;
	services.wlsunset.enable = true;
}
