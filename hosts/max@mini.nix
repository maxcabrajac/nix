{ pkgs, maxLib, ... } @ inputs: {
	imports = [
		../profiles/hyprland.nix
		../profiles/terminal.nix
		../profiles/fonts.nix
	];

	home = {
		packages = (maxLib.scriptDir inputs ../scripts).all;
	};

	# nix-based pam.so doesn't seem to work on arch
	programs.hyprlock.package = pkgs.emptyDirectory;

	nixGL = {
		packages = pkgs.nixgl;
	};
}
