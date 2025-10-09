{ pkgs, ... }: {
	web = {
		browser = pkgs.vivaldi;
		sites = [
			{
				alias = "h";
				name = "Hanabi";
				bookmark = "hanab.live";
			}
			{
				alias = "lv";
				name = "H-group Conventions";
				bookmark = "hanabi.github.io/learning-path#level-summary";
				search_engine = "hanabi.github.io/level-%%";
			}
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
