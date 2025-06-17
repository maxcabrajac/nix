{ config, ... }: let
	theme = config.global.color.themer.zathura;
in {
	global.color.maps.zathura = {
		main = main: {
			fg = main.fg.hhex;
			bg = main.bg.hhex;
		};
	};
	programs.zathura = {
		mappings = {
			"n" = "scroll down";
			"N" = "navigate next";
			"e" = "scroll up";
			"E" = "navigate previous";
			"i" = "scroll right";
			"h" = "scroll left";
			"u" = "zoom in";
			"y" = "zoom out";
			"k" = "search forward";
			"K" = "search backward";
		};

		options = {
			recolor = true;
			recolor-lightcolor = theme.bg;
			recolor-darkcolor = theme.fg;
			recolor-keephue = true;
			adjust-open = "width";
			guioptions = "";
		};
	};
}
