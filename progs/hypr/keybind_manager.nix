{ lib, config, maxLib, ... }:
let
	inherit (builtins) map;
	inherit (lib) pipe concatStringsSep;
	inherit (maxLib) checkCollisions;
	fpipe = lib.flip pipe;

	modMap = {
		"M" = "SUPER";
		"S" = "SHIFT";
		"C" = "CTRL";
		"A" = "ALT";
	};
	flagIf = b: flag: if b then flag else "";
	process_bind = { mods, key, repeat, description, dispatcher, args }: let
		modMask = pipe mods [ (map (m: modMap.${m})) (concatStringsSep " ") ];
	in
		lib.listToAttrs [
			{
				# d = description (even if empty)
				name = "bind" + "d" + flagIf repeat "e";
				value = concatStringsSep ", " ([ modMask key description dispatcher ] ++ args);
			}
		];

	processed = pipe config.programs.hypr.keybinds [
		(map process_bind)
		lib.zipAttrs
	];
in {
	options.programs.hypr.keybinds = with lib; with types; let
		keybind = submodule {
			options = {
				mods = mkOption {
					type = types.either
						(strMatching "(M|S|C|A)*")
						(types.listOf (types.enum ["M" "S" "C" "A"]));
					apply = fpipe [
						(v: if isString v then lib.stringToCharacters v else v)
						lib.unique
						naturalSort
					];
				};
				key = mkOption { type = str; };
				dispatcher = mkOption { type = str; };
				args = mkOption {
					type = listOf types.str;
					default = [];
				};
				repeat = mkOption {
					type = bool;
					default = false;
				};
				description = mkOption {
					type = str;
					default = "";
				};
			};
		};
	in
		mkOption {
			default = [ ];
			type = listOf keybind;
			apply = checkCollisions "hypr.keybinds" ({ mods, key, ... }: "${concatStrings mods}-${key}");
		};


	config = {
		programs.hypr.keybinds = let
			global_to_hypr = { mods, key, repeat, description, cmd }: {
				inherit key mods description repeat;
				dispatcher = "execr";
				args = [ cmd ];
			};
		in
			map global_to_hypr config.global.keybinds;

		wayland.windowManager.hyprland.settings = processed;
	};
}
