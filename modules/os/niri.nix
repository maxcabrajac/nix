{ lib, ... }: {
	os.base = { config, pkgs, ... }: let
		niriEnabledOnHm = config.lib.humans.hmConfigs
			|> lib.any (lib.attrByPath [ "programs" "niri" "enable" ] false)
		;
	in {
		programs.niri = {
			enable = niriEnabledOnHm;
			useNautilus = lib.mkDefault false;
		};

		environment.systemPackages = lib.optional niriEnabledOnHm pkgs.xwayland-satellite;
	};
}
