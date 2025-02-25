{ pkgs, maxLib, ... } @ inputs: {
	imports = [
		../profiles/hyprland.nix
		../profiles/terminal.nix
	];

	home = {
		packages = (maxLib.scriptDir inputs ../scripts).all;
	};

	nixGL = {
		packages = pkgs.nixgl;
	};
}
