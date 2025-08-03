{ lib, util, pkgs, config, ... }: let
	cfg = config.color;
in {
	options.color = {
		schemes = lib.mkOption {
			type = with lib.types; with util.types;
				# map.colorName = color
				attrsOf <| attrsOf <| either color <| listOf color;
		};

		scheme = lib.mkOption {
			type = with lib.types; str;
		};

		maps = lib.mkOption {
			type = with lib.types;
				# app.scheme = scheme: app_specific_config
				attrsOf <| attrsOf <| functionTo raw;
		};

		themer = lib.mkOption {
			type = with lib.types; raw;
		};
	};

	config.color = {
		schemes = {
			ayu = rec {
				fg        = "#E6E1CF";
				bg        = "#0F1419";
				gray      = "#5C6773";
				colors    = [ blue orange green cream light_red cyan purple ];
				bg1       = "#14191F";
				bg2       = "#151A1E";
				bg3       = "#253340";
				gray1     = "#3E4B59";
				gray2     = "#2D3640";
				blue      = "#39A3D9";
				cyan      = "#95E6CB";
				green     = "#B8CC52";
				red       = "#FF3333";
				light_red = "#F26D78";
				orange    = "#FF7733";
				orange2   = "#F29718";
				orange3   = "#FFB454";
				yellow    = "#E7C547";
				brown     = "#E6B673";
				cream     = "#FFEE99";
				purple    = "#D2A6FF";
			};
		};

		themer =
			cfg.maps
			|> lib.mapAttrs (_: mapsForApp:
				let
					mapper = if mapsForApp ? ${cfg.scheme}
						then mapsForApp.${cfg.scheme}
						else mapsForApp.default;
				in
					mapper cfg.schemes.${cfg.scheme}
			)
		;
	};
}
