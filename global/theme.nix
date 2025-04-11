{ lib, maxLib, pkgs, config, ... }: {
	options.global.color = {
		scheme = lib.mkOption {
			type = with lib.types; attrsOf (attrsOf maxLib.types.color);
		};
	};

	config.global.color.scheme.ayu = {
		fg        = "#E6E1CF"; # THEME_DEF
		blue      = "#39A3D9"; # THEME_PRI
		cyan      = "#95E6CB";
		green     = "#B8CC52"; # THEME_TER
		red       = "#FF3333"; # THEME_ALERT
		light_red = "#F26D78";
		orange    = "#FF7733"; # THEME_SEC
		orange2   = "#F29718";
		orange3   = "#FFB454";
		yellow    = "#E7C547";
		brown     = "#E6B673";
		cream     = "#FFEE99"; # THEME_DEF_ALT
		purple    = "#D2A6FF";
		bg        = "#0F1419"; # THEME_BG
		bg1       = "#14191F";
		bg2       = "#151A1E";
		bg3       = "#253340";
		gray      = "#5C6773"; # THEME_DEF_FADE
		gray1     = "#3E4B59";
		gray2     = "#2D3640";
	};
}

