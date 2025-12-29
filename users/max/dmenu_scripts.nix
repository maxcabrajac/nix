{ pkgs, lib, config, ... }: let
	cfg = config.programs.dmenu_scripts;
in {
	programs.dmenu_scripts = {
		enable = config.profiles.gui;
		dmenu = pkgs.writers.writeDashBin "dmenu" "exec ${lib.getExe pkgs.fuzzel} --dmenu";
	};

	global.keybinds = lib.mkIf cfg.enable {
		M-O = {
			description = "Start browsing with dmenu_search";
			sh = let
				dmenu_search = lib.getExe cfg.search.package;
				browser = lib.getExe config.web.browser;
			in
				/* sh */ ''





					link=$(${dmenu_search})
					if [ -n "$link" ]; then
						exec ${browser} $link
					fi
				''
				;
		};
	};
}
