{ lib, util, ... }: with lib; let
	inherit (util) checkCollisions;
in {
	options.global.keybinds = with types; let
		keybind = submodule {
			options = {
				mods = mkOption {
					type = types.either
						(strMatching "(M|S|C|A)*")
						(types.listOf (types.enum ["M" "S" "C" "A"]));
					apply = mods:
						if isString mods then lib.stringToCharacters mods else mods
						|> naturalSort
						|> lib.unique
					];
				};
				key = mkOption { type = str; };
				cmd = mkOption { type = str; };
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
	in mkOption {
		type = listOf keybind;
		default = [];
		apply = checkCollisions "keybinds" ({mods, key, ...}: "${concatStrings mods}-${key}");
	};
}
