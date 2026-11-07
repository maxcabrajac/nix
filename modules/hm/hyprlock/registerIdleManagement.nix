{ lib, ... }: {
	hm.base = { config, ... }: let
		cfg = config.programs.hyprlock;
	in {
		idleManagement.locker = lib.mkIf cfg.enable <| lib.mkDefault <| lib.getExe cfg.package;
	};
}
