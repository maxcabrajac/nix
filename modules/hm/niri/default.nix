{ inputs, config, lib, pkgs, ... } : {
	imports = [
		inputs.niri-flake.homeModules.niri
	];

	programs.niri.package = pkgs.niri;

	home.packages = lib.optional config.programs.niri.enable pkgs.nautilus;

	# xdg.portal.config.niri = {
	# 	"org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
	# };
}
