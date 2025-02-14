{ pkgs, lib ... }:
with lib;
let cfg = config.programs.hellohelo;
{
	options = {
		programs.hellohelo.enable = mkEnableOption "hellohelo";
	};

	config = mkIf cfg.enable {
		home.packages = [ pkgs.hello ];
	}
}
