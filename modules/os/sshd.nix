{ lib, ... }: {
	os.base.services.openssh.settings = lib.mkDefault {
		PasswordAuthentication = false;
		KbdInteractiveAuthentication = false;
	};
}
