{ lib, config, ... }: {
	programs.elephant.provider.websearch.settings = {
		default_score = 1;
		match_score = 1000000;
		engines = let
			baseEngines = config.web.sites
				|> map ({ name, alias, bookmark, search_engine }: {
					inherit alias name;
					url = "https://${bookmark}";
					search_url = lib.mkIf (!isNull search_engine) (builtins.replaceStrings ["%%"] ["%TERM%"] "https://${search_engine}");
					default = false;
				});
			defaultEngine = {
				name = "the Internet";
				alias = "search";
				search_url = builtins.replaceStrings ["%%"] ["%TERM%"] "https://${config.web.default_search_engine}";
				default = true;
			};
		in
			baseEngines ++ [defaultEngine]
		;
	};
}
