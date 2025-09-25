{pkgs, ...}: {
	home.packages = with pkgs; [
		heroic
		gamescope
	];
}
