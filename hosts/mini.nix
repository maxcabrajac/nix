{ pkgs, lib, helpers, ... }: {
	profile = {
		hyprland = true;
		terminal = true;
		fonts = true;
	};

	home = {
		packages = lib.flatten [
			pkgs.nixd
			# helpers.all
		];
	};

	global.web.sites = let
		mkSite = name: alias: bookmark: search_engine:
			{ inherit name alias bookmark search_engine; };
	in [
		{ name = "Gmail"; bookmark = "mail.google.com"; }
		(mkSite "YouTube" "y" "youtube.com" "youtube.com/results?search_query=%%")

		# Self-hosted
		(mkSite "Home Assistant" "ha" "ha.helo.cabrajac.com" null)
		(mkSite "Jellyfin" "jelly" "jelly.pudim.xyz" null)

		# Hanabi
		(mkSite "Hanabi" "h" "hanab.live" null)
		(mkSite "HGroup Hanabi Conventions" "lv" "hanabi.github.io/learning-path#level-summary" "hanabi.github.io/level-%%")
	];

	# nix-based pam.so doesn't seem to work on arch
	programs.hyprlock.package = pkgs.emptyDirectory;

	nixGL = {
		packages = pkgs.nixgl;
	};
}
