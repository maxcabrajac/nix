{ lib, ... }: {
	hm.base = { osConfig, ... }: {
		programs.bluetuith.enable = lib.mkDefault <| osConfig.hardware.bluetooth.enable or false;
	};
}
