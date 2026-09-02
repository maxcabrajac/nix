{
	os.base = { config, lib, ... }: let
		cfg = config.hardware.nvidia;
	in {
		system.switch.inhibitors = lib.mkIf cfg.enabled {
			nvidia-driver = lib.toString cfg.package;
		};
	};
}
