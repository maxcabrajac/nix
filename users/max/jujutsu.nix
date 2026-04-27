{ lib, config, ... }: let
	cfg = config.programs.jujutsu;
in {
	programs.jujutsu = {
		enable = true;
		settings = {
			ui.default-command = "log";
			templates = {
				git_push_bookmark = ''"maxcabrajac-" ++ change_id.short()'';
			};

			revset-aliases = let
				not = x: "(~${x})";
				ancestors = x: "(::${x})";
				union = xs: "(${lib.concatStringsSep "|" xs})";
			in {
				"unbooked()" = not <| ancestors <| union <| [ "bookmarks()" "remote_bookmarks()" ];
			};

			aliases = {
				gc = ["abandon" "-r" "unbooked()"];
			};
		};
	};
	home.shellAbbrs.nn = lib.mkIf cfg.enable "jj";
}
