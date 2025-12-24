{ inputs, lib, ... }: {
	imports = [inputs.walker.homeManagerModules.default];
	programs = {
		elephant = {
			providers = lib.mkDefault [
				"desktopapplications"
				"clipboard"
				"symbols"
				"providerlist"
				"websearch"
				"windows"
			];
		};
		walker = {
			runAsService = true;
		};
	};
}
