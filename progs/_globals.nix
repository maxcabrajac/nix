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
				type = listOf keybind;
				default = [];
			};

		web = let
			search_engine = strMatching ".*%%.*";
			site = submodule ({config, ...}: {
				options = {
					name = mkOption { type = str; };
					alias = mkOption { type = str; default = config.name; };
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
