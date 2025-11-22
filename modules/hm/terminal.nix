{ lib, config, ... }: let
	cfg = config.terminal;
in {
	options.terminal = {
		package = lib.mkOption {
			type = with lib.types; nullOr package;
		};

		bin = lib.mkOption {
			type = lib.types.str;
		};
	};

	config = {
		terminal.bin = lib.getExe cfg.package;
		home.packages = [ cfg.package ];
	};
}
