{ lib, ... }: {
	os.base.hardware.nvidia = {
		open = lib.mkDefault true;
		nvidiaSettings = lib.mkDefault false;
		powerManagement.enable = lib.mkDefault true;
	};
}
