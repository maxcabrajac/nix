{ config, lib, util, inputs, ... }: let
	homes = util.readDir config.dirs.users
		|> map ({ name, path, ... }: {
			inherit name;
			value.imports = util.allNixFiles path;
		})
		|> lib.listToAttrs
	;
	overlays = config.flake.overlays |> lib.attrValues;

	hmConfig = { user, system, alias ? null }: inputs.home-manager.lib.homeManagerConfiguration {
		pkgs = import inputs.nixpkgs { inherit system overlays; };
		extraSpecialArgs = { inherit inputs util; };
		modules = lib.flatten [
			(config.flake.homeModules |> lib.attrValues)
			homes.${user}
			({ config, ... }: {
				home = {
					username = if alias != null then alias else user;

					# TODO: Move this somewhere else
					sessionVariables.HOME_MANAGER_VARIANT = config.variant;
				};
			})
		];
	};
in {
	# TODO: do something to connect this to os.humans
	options = {
		dirs.users = lib.mkOption {
			type = lib.types.path;
		};
	};

	config.flake = {
		homeModules.variantSelector = { config, ... }: {
			options.variant = lib.mkOption {
				type = lib.types.enum [ "default" ];
				default = "default";
			};
		};
		homeConfigurations = config.systems
			|> map (system:
				homes
				|> lib.attrNames
				|> map (user: let
						base = hmConfig { inherit user system; };
						variants = base.options.variant.type.functor.payload.values;
					in
						variants
						|> map (variant: {
							"${user}#${variant}@${system}" = base.extendModules {
								modules = [{ inherit variant; }];
							};
						})
				)
			)
			|> lib.flatten
			|> lib.mergeAttrsList
		;
	};
}
