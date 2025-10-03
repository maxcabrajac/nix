{ lib, util, config, ... }: with lib; let
	inherit (util.types) into apply;
in {
	options.global.keybinds = with types; let
		keybind = submodule ({ config, ... }: {
			options = {
				mods = mkOption {
					type = strMatching "(M|S|C|A)*"
						|> into (listOf (enum ["M" "S" "C" "A"])) lib.stringToCharacters
						|> apply naturalSort
						|> apply lib.unique
					;
				};
				key = mkOption { type = str; };

				pkg = mkOption {
					type = package;
				};

				cmd = mkOption {
					type =
						str
						|> into (listOf str) (lib.splitString " ")
					;
					default = lib.getExe config.pkg;
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
		});
	in mkOption {
		type = listOf keybind;
		default = [];
	};

	config.assertions = [
		(util.assertions.noCollisions "global.keybinds" ({mods, key, ...}: "${lib.concatStrings mods}-${key}") config.global.keybinds)
	];
}
