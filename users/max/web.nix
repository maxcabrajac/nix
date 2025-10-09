{ pkgs, ... }: {
	web = {
		browser = pkgs.vivaldi;
		sites = [
			{ name = "Hanabi"; alias = "h"; bookmark = "hanab.live"; }
		];
	};
}
