{ lib, assertNoCollisions, ... }: {
	hm.base = { pkgs, config, ... }: with lib; with types; let
		cfg = config.web;
		searchEngineT = strMatching ".*%%.*";
		websiteT = submodule ({config, ...}: {
			options = {
				name = mkOption {
					type = str;
				};
				alias = mkOption {
					type = str;
					default = toLower config.name;
					defaultText = literalExpression "lib.toLower config.name";
				};
				bookmark = mkOption {
					type = str;
				};
				search_engine = mkOption {
					type = nullOr searchEngineT;
					default = null;
				};
			};
		});
	in {
		options.web = with types; {
			browser = mkOption {
				type = package;
				default = pkgs.firefox;
			};

			sites = mkOption {
				type = listOf websiteT;
				default = [];
			};

			default_search_engine = mkOption {
				type = either websiteT searchEngineT;
				default = "google.com/search?q=%%";
				apply = se:
					if isString se then
						se
					else
						throwIf (isNull se.search_engine)
							"web.default_search_engine.search_engine is null/not set" se.search_engine;
			};
		};

		config = {
			assertions = [
				(assertNoCollisions "web.sites" (x: x.alias) cfg.sites)
			];

			home.packages = lib.mkIf config.profiles.gui [ cfg.browser ];
		};
	};
}
