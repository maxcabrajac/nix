{ lib, ... }: {
	os.base.security.rtkit.enable = lib.mkDefault true;
}
