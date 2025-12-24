{ inputs, pkgs, lib, config, ... }: let
	cfg = config.programs.niri;
in {
	imports = [
		inputs.niri-flake.homeModules.niri
	];

	programs.niri.package = pkgs.niri;
	xdg.configFile.niri-config.enable = lib.mkForce (cfg.enable && cfg.finalConfig != null);
}
