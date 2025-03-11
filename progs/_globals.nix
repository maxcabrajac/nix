{ lib, pkgs, config, maxLib, ... }: with lib; let
	fpipe = flip pipe;
	inherit (maxLib) checkCollisions;
in {
	options.global = with types; {
		keybinds = let
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
		in
			mkOption {
				type = listOf keybind;
				default = [];
				apply = checkCollisions "global.keybinds" ({mods, key, ...}: "${concatStrings mods}-${key}");
			};

		web = let
			search_engine = strMatching ".*%%.*";
			site = submodule ({config, ...}: {
				options = {
					name = mkOption { type = str; };
					alias = mkOption { type = str; default = toLower config.name; };
					bookmark = mkOption { type = str; };
					search_engine = mkOption {
						type = nullOr search_engine;
						default = null;
					};
				};
			});
		in {
			sites = mkOption {
				type = listOf site;
				default = [];
				apply = checkCollisions "global.web.sites" (x: x.alias);
			};

			default_search_engine = mkOption {
				type = either site search_engine;
				default = "google.com/search?q=%%";
				apply = se:
					if isString se then
						se
					else
						throwIf (isNull se.search_engine)
							"global.web.default_search_engine.search_engine is null/not set" se.search_engine;
			};
		};
	};
}
