{ config, lib, util, inputs, ... }: let
	homes = util.readDir config.dirs.users
		|> map ({ name, path, ... }: {
			inherit name;
			value.imports = util.allNixFiles path;
		})
		|> lib.listToAttrs
	;
	overlays = config.flake.overlays |> lib.attrValues;

	hmConfig = { user, system }: inputs.home-manager.lib.homeManagerConfiguration {
		pkgs = import inputs.nixpkgs { inherit system overlays; };
		extraSpecialArgs = { inherit inputs util; };
		modules = lib.flatten [
			(config.flake.homeModules |> lib.attrValues)
			homes.${user}
			{ home.username = lib.mkDefault user; }
			{ nixpkgs.config.allowUnfree = true; }
		];
	};
in {
	# TODO: do something to connect this to os.humans
	options = {
		dirs.users = lib.mkOption {
			type = lib.types.path;
		};

		userAliases = lib.mkOption {
			type = lib.types.attrsOf <| lib.types.listOf lib.types.str;
		};
	};

	config = {
		userAliases = homes
			|> lib.attrNames
			|> (names: lib.genAttrs names (x: [x]))
		;

		flake = {
			homeModules.variantSelector.options.variant = lib.mkOption {
				type = lib.types.enum [ "default" ];
				default = "default";
			};

			homeConfigurations = config.systems
				|> map (system:
					homes
					|> lib.attrNames
					|> map (user: let
							base = hmConfig { inherit user system; };
							variants = base.options.variant.type.functor.payload.values;
							aliases = config.userAliases.${user};
						in
							lib.cartesianProduct { variant = variants; alias = aliases; }
							|> map ({variant, alias}: {
								"${alias}#${variant}@${system}" = base.extendModules {
									modules = [
										{ inherit variant; }
										({ config, ... }: {
											home = {
												username = alias;
												sessionVariables.HOME_MANAGER_VARIANT = config.variant;
											};
										})
									];
								};
							})
					)
				)
				|> lib.flatten
				|> lib.mergeAttrsList
			;
		};
	};
}
