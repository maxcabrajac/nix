{ lib, ... }: {
	os.base.services.displayManager.ly.settings = {
		session_log = lib.mkDefault null;
	};
}
