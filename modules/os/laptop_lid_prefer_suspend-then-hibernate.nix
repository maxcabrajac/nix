{ lib, ... }: {
	os.base.services.logind.settings.Login.HandleLidSwitch = lib.mkDefault "suspend-then-hibernate";
}
