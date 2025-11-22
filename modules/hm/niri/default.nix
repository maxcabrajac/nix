{ inputs, pkgs, ... } : {
	imports = [
		inputs.niri-flake.homeModules.niri
	];

	programs.niri.package = pkgs.niri;
}
