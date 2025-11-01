{ pkgs, ... }: {
	web = {
		browser = pkgs.vivaldi;
		sites = [
			{
				alias = "ha";
				name = "Home Assistant";
				bookmark = "ha.helo.cabrajac.com";
			}
			{
				alias = "y";
				name = "Home Assistant";
				bookmark = "youtube.com";
				search_engine = "youtube.com/results?search_query=%%";
			}
		];
	};
}
