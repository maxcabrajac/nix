{ withSystem, ... }: let
	mod = { pkgs, ... }: {
		config._module.args = {
			withSystem' = withSystem pkgs.stdenv.hostPlatform.system;
			withSystem = withSystem pkgs.stdenv.hostPlatform.system ({ config, ... }: config);
		};
	};
in {
	os.base = mod;
	hm.base = mod;
	nvf.base = mod;
}
