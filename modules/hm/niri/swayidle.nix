{ lib, ... }: {
	hm.base = { config, ... }: let
		cfg = config.programs.niri;
		niri = lib.getExe cfg.package;
	in {
		options.programs.niri.idleTimeout = lib.mkOption {
			type = lib.types.number;
			default = 5 * 60;
		};

		config.services.swayidle = lib.mkIf cfg.enable {
			enable = true;
			timeouts = [
				{
					timeout = cfg.idleTimeout;
					command = "${niri} msg action power-off-monitors";
					resumeCommand = "${niri} msg action power-on-monitors";
				}
			];
		};
	};
}
