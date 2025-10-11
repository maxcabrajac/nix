{pkgs, lib, ...}: {
	home.packages = with pkgs; [
		heroic
		gamescope
	];

	global.keybinds = [
		# { mods = "M"; key = "G"; pkg = pkgs.heroic; }
	];
}
