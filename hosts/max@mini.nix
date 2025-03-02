{ pkgs, maxLib, ... } @ inputs: {
	imports = [
		../profiles/hyprland.nix
		../profiles/terminal.nix
		../profiles/fonts.nix
	];

	home = {
		packages = (maxLib.scriptDir inputs ../scripts).all;
	};

	programs.hyprlock.package = pkgs.emptyDirectory;

	nixGL = {
		packages = pkgs.nixgl;
	};
}
