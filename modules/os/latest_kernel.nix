{ lib, ... }: {
	os.base = { pkgs, ... }: {
		config.boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
	};
}
