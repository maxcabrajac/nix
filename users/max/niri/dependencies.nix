{ config, lib, pkgs, ... }: lib.mkIf config.programs.niri.enable {
	global.keybinds = {
		M-Space.pkg = config.programs.walker.package;
		M-O.sh = "${lib.getExe config.programs.walker.package} -m websearch";
	};
 	programs.lf.useAsXdgPortalOn.niri = true;
 	programs.walker.enable = true;
 	# programs.anyrun.enable = true;
 	services.playerctld.enable = true;
 	services.wlsunset.enable = true;
	services.swww.enable = true;
}
