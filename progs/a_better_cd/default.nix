{lib, config, pkgs, maxLib, ...}: let
	cfg = config.programs.abcd;
	inherit (maxLib.makeScript { inherit pkgs; } ./abcd.sh) abcd;
in {
	options.programs.abcd = {
		enable = lib.mkEnableOption "abcd";
	};

	config = lib.mkIf cfg.enable {
		home.packages = [ abcd ];
	};
}
