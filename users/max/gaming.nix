{ pkgs, lib, config, ...}: lib.mkIf config.profiles.games {
	home.packages = with pkgs; [
		heroic
		gamescope
	];

	global.keybinds = [
		# { mods = "M"; key = "G"; pkg = pkgs.heroic; }
	];

	web.sites = [
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
	];
}
