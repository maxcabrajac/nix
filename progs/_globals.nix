{ lib, pkgs, config, ... }: let
	fpipe = lib.flip lib.pipe;
in {
	options.global = with lib; with types; {
		keybinds = let
			keybind = submodule {
				options = {
					mods = mkOption {
						type = types.strMatching "(M|S|C|A)*";
						apply = fpipe [ lib.stringToCharacters lib.unique ];
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
		in
			mkOption {
				default = [ ];
				type = listOf keybind;
			};
	};
}
