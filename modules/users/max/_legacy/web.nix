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
				name = "YouTube";
				bookmark = "youtube.com";
				search_engine = "youtube.com/results?search_query=%%";
			}
			{
				alias = "sudoku";
				name = "Logic Masters";
				bookmark = "logic-masters.de/Raetselportal";
			}
		];
	};
}
