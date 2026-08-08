{ lib, ... }: {
	hm.base = { config, ... }: {
		home.homeDirectory = lib.mkDefault "/home/${config.home.username}";
	};
}
