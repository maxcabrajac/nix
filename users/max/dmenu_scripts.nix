{ pkgs, lib, config, ... }: let
	cfg = config.programs.dmenu_scripts;
in {
	programs.dmenu_scripts = {
		enable = true;
		dmenu = pkgs.writers.writeDashBin "dmenu" "exec ${lib.getExe pkgs.fuzzel} --dmenu";
	};

	global.keybinds = [
		{ mods = "M"; key = "O"; pkg = cfg.search.package; }
	];
}
