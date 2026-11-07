{ lib, ... }: {
	os.base = { config, ... }: {
		security.pam.services =
			config.lib.humans.hmConfigs
			|> lib.any (lib.attrByPath ["programs" "hyprlock" "enable"] false)
			|> (cond: lib.mkIf cond { hyprlock = {}; })
		;
	};
}
