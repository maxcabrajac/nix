{ pkgs, lib, config, ... }: {
	global.keybinds = let
		playerctl = lib.getExe pkgs.playerctl;
		binds = {
			XF86AudioPlay.sh = /* sh */ "${playerctl} play-pause";
			XF86AudioNext.sh = /* sh */ "${playerctl} next";
			XF86AudioPrev.sh = /* sh */ "${playerctl} previous";
		} |> lib.mapAttrs (_: bind: lib.mkDefault bind);
	in lib.mkIf config.services.playerctld.enable binds;
}
