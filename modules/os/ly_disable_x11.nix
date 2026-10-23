{ lib, ... }: {
	os.base.services.displayManager.ly.x11Support = lib.mkDefault false;
}
