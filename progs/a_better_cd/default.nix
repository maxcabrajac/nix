{lib, config, pkgs, ...}: let
	cfg = config.programs.abcd;
	package = pkgs.makeScript { inherit pkgs; } ./abcd.sh;
in {
	options.programs.abcd = {
		enable = lib.mkEnableOption "abcd";
	};

	config = lib.mkIf cfg.enable {
		home.packages = [ package ];
	};
}
