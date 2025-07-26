{ lib, config, ... }: let
	cfg = config.programs.bemenu;
	theme = config.color.themer.bemenu;
in {
	color.maps.bemenu = {
		main = main: let color = builtins.elemAt main.color 0; in {
			tb = color.hhex;
			tf = main.bg.hhex;
			fb = main.bg.hhex;
			ff = color.hhex;
			hb = color.hhex;
			hf = main.bg.hhex;
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
