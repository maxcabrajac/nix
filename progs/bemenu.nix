{ ... }: {
	programs.bemenu = {
		settings = {
			line-height = 20;
			fn = "Fira Code Semi-Bold";
			tb = "#$THEME_PRI";
			tf = "#$THEME_BG";
			fb = "#$THEME_BG";
			ff = "#$THEME_PRI";
			hb = "#$THEME_PRI";
			hf = "#$THEME_BG";
			hp = 8;
		};
	};

	global.keybinds = [
		{ mods = "M"; key = "space"; cmd = "menu_run"; }
	];
}
