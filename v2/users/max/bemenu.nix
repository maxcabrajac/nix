{ lib, config, ... }: let
	cfg = config.programs.bemenu;
	theme = config.color.themer.bemenu;
in {
	color.maps.bemenu = {
		default = scheme: let color = builtins.elemAt scheme.colors 0; in {
			tb = color.hhex;
			tf = scheme.bg.hhex;
			fb = scheme.bg.hhex;
			ff = color.hhex;
			hb = color.hhex;
			hf = scheme.bg.hhex;
		};
	};

	programs.bemenu = {
		enable = true;
		settings = {
			line-height = 20;
			fn = "Fira Code Semi-Bold";
			hp = 8;
		} // theme;
	};

	# programs.dmenu_scripts.dmenu = cfg.package;

	# global.keybinds = [
	# 	{ mods = "M"; key = "space"; cmd = "menu_run"; }
	# ];
}
