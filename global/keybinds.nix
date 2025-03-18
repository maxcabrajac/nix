{ lib, maxLib, ... }: with lib; let
	fpipe = flip pipe;
	inherit (maxLib) checkCollisions;
in {
	options.global.keybinds = with types; let
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
		apply = checkCollisions "global.keybinds" ({mods, key, ...}: "${concatStrings mods}-${key}");
	};
}
