{ pkgs, lib, config, ... }: {
	programs.dmenu_scripts = {
		enable = true;
		dmenu = pkgs.writers.writeDashBin "dmenu" "exec ${lib.getExe pkgs.fuzzel} --dmenu";
	};
}
