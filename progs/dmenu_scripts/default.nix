{ pkgs, lib, maxLib, config, ... }: with lib; {
	imports = [
		./search.nix
	];

	options.programs.dmenu_scripts = with types; {
		enable = mkEnableOption "dmenu_scripts";
		dmenu = mkPackageOption null "dmenu" { nullable = false; default = null; };
	};
}
