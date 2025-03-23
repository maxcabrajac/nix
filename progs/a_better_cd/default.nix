{lib, config, pkgs, ...}: let
	cfg = config.programs.abcd;
	inherit (pkgs.makeScript { inherit pkgs; } ./abcd.sh) abcd;
in {
	options.programs.abcd = {
		enable = lib.mkEnableOption "abcd";
	};

	config = lib.mkIf cfg.enable {
		home.packages = [ abcd ];
	};
}
