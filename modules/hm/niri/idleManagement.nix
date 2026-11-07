{ lib, ... }: {
	hm.base = { config, ... }: let
		cfg = config.programs.niri;
		niri = lib.getExe cfg.package;
	in {
		config = lib.mkIf cfg.enable {
			services.swayidle.enable = true;
			idleManagement.timeouts.screenOff = {
				command = "${niri} msg action power-off-monitors";
				resumeCommand = "${niri} msg action power-on-monitors";
			};
		};
	};
}
