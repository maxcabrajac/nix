{ pkgs, lib, config, ... }: let
	cfg = config.programs.dmenu_scripts;
in {
	programs.dmenu_scripts = {
		enable = true;
		dmenu = pkgs.writers.writeDashBin "dmenu" "exec ${lib.getExe pkgs.fuzzel} --dmenu";
	};

	global.keybinds = [
		{
			mods = "M";
			key = "O";
			sh = let
				dmenu_search = lib.getExe cfg.search.package;
				browser = lib.getExe config.web.browser;
			in
				/* sh */''
					link=$(${dmenu_search})
					if [ -n "$link" ]; then
						exec ${browser} $link
					fi
				''
			;
		}
	];
}
