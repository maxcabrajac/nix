{ config, lib, util, inputs, ... }: {
	# TODO: do something to connect this to os.humans
	options = {
		dirs.users = lib.mkOption {
			type = lib.types.path;
		};
	};

	config.flake = {
		homeConfigurations =
			config.flake.nixosConfigurations
			|> lib.mapAttrs (host: osConfig:
				osConfig.config.home-manager.users
				|> lib.mapAttrs' (user: hmConfig: {
					name = "${user}@${host}";
					value = { config = hmConfig; };
				})
			)
			|> lib.attrValues
			|> lib.mergeAttrsList
		;
	};
}
