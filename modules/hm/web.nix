{ lib, assertNoCollisions, ... }: {
	hm.base = { pkgs, config, ... }: with lib; with types; let
		cfg = config.web;
		prependHttps = mapNullable (s:
			if s |> hasInfix "://"
			then s
			else "https://${s}"
		);

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
					type = nullOr str;
					default = null;
					apply = prependHttps;
				};
				search_engine = mkOption {
					type = nullOr <| strMatching ".*%%.*";
					default = null;
					apply = prependHttps;
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
				type = coercedTo str (search_engine: {
					name = "Internet";
					alias = "search";
					inherit search_engine;
				}) websiteT;
			};
		};

		config = {
			assertions = [
				(assertNoCollisions "web.sites" (x: x.alias) cfg.sites)
				{
					assertion = config.web.default_search_engine.search_engine != null;
					message = "Invalid web.default_search_engine";
				}
			];
			web.default_search_engine = mkDefault "google.com/search?q=%%";

			home.packages = lib.mkIf config.profiles.gui [ cfg.browser ];
		};
	};
}
