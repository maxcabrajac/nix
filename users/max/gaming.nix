{ pkgs, lib, config, ...}: lib.mkIf config.profiles.games {
	home.packages = with pkgs; [
		heroic
		gamescope
	];

	web.sites = [
		{
			alias = "lv";
			name = "H-group Conventions";
			bookmark = "hanabi.github.io/learning-path#level-summary";
			search_engine = "hanabi.github.io/level-%%";
		}
	];
}
