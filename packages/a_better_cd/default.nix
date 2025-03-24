{...}: rec {
	homeManagerModule = { lib, pkgs, config, ... }: let
		cfg = config.programs.abcd;
	in {
		options.programs.abcd = {
			enable = lib.mkEnableOption "abcd";
		};

		config = lib.mkIf cfg.enable {
			home.packages = [ (pkgs.abcd or (packages pkgs).abcd) ];
		};
	};

	packages = pkgs: {
		abcd = pkgs.makeScript { inherit pkgs; } ./abcd.sh;
	};
}
