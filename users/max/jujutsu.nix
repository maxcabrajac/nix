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
		};
	};
	home.shellAbbrs.nn = lib.mkIf cfg.enable "jj";
}
