{ lib, ... }: {
	os.base = { config, ... }: {
		options = {
			humans = lib.mkOption {
				type = with lib.types; attrsOf (submodule {
					options = {
						os = lib.mkOption {
							type = raw;
							default = {};
						};

						hm = lib.mkOption {
							type = nullOr deferredModule;
							default = null;
						};
					};
				});
				default = {};
			};
		};

		config = {
			users.users = config.humans |> lib.mapAttrs (_: h: {
				isNormalUser = true;
				isSystemUser = false;
			} // h.os);

			home-manager.users = config.humans
				|> lib.filterAttrs (_: h: h.hm != null)
				|> lib.mapAttrs (_: h: h.hm);

			lib.humans.hmConfigs = config.humans
				|> lib.filterAttrs (_: h: h.hm != null)
				|> lib.attrNames
				|> map (name: config.home-manager.users.${name});
		};
	};
}
