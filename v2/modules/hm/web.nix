{ lib, util, ... }: with lib; let
	inherit (util) checkCollisions;
in {
	options.web = with types; let
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
			apply = checkCollisions "web.sites" (x: x.alias);
		};

		default_search_engine = mkOption {
			type = either site search_engine;
			default = "google.com/search?q=%%";
			apply = se:
				if isString se then
					se
				else
					throwIf (isNull se.search_engine)
						"web.default_search_engine.search_engine is null/not set" se.search_engine;
		};
	};
}
