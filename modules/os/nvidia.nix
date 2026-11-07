{ lib, ... }: {
	os.base.hardware.nvidia = {
		open = lib.mkDefault true;
		nvidiaSettings = lib.mkDefault false;
	};
}
