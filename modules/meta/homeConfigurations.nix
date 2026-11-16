{ config, lib, inputs, withSystem, ... }: {
	config = {
		perSystem = { pkgs, ... }: {
			options.homeConfigurations = lib.mkOption {
				type = lib.types.lazyAttrsOf lib.types.raw;
				internal = true;
				readOnly = true;
			};

			config.homeConfigurations =
				config.user
				|> lib.mapAttrs (username: module:
					inputs.home-manager.lib.homeManagerConfiguration {
						inherit pkgs;
						extraSpecialArgs = {
							# TODO: Remove these
							inherit inputs;
							osConfig = null;
						};
						modules = [
							module
							# Can this be moved somewhere else?
							{ home.username = lib.mkDefault username; }
						];
					}
				)
			;
		};

		flake.homeConfigurations = config.systems
			|> lib.concatMap (s:
				withSystem s ({ config, ... }: config.homeConfigurations)
				|> lib.attrsToList
				|> map (x: x // { name = "${s}-${x.name}"; })
			)
			|> lib.listToAttrs
		;
	};
}
