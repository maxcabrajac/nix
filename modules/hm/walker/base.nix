{ inputs, lib, ... }: {
	hm.base = {
		imports = [inputs.walker.homeManagerModules.default];
		programs = {
			elephant = {
				providers = lib.mkDefault [
					"desktopapplications"
					"clipboard"
					"symbols"
					"providerlist"
					"menus"
					"windows"
				];
			};
			walker = {
				runAsService = true;
				config.providers.default = [ "desktopapplications" ];
			};
		};
	};
}
