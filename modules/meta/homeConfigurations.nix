{ config, lib, inputs, ... }: let
	overlays = config.flake.overlays |> lib.attrValues;

	# TODO: Refactor this. This is bad...
	hmConfig = { module, system }: inputs.home-manager.lib.homeManagerConfiguration {
		pkgs = import inputs.nixpkgs { inherit system overlays; };
		# TODO: Remove this
		extraSpecialArgs = { inherit inputs; };
		modules = [
			module
			{ nixpkgs.config.allowUnfree = true; }
		];
	};

	getUsername = (x:
		x
		|> lib.splitString "#"
		|> lib.head
	);
in {
	options = {
		userAliases = lib.mkOption {
			type = lib.types.attrsOf <| lib.types.listOf lib.types.str;
		};
	};

	config = {
		userAliases = config.user
			|> lib.attrNames
			|> map getUsername
			|> lib.unique
			|> (names: lib.genAttrs names (x: [x]))
		;

		flake = {
			homeConfigurations = config.systems
				|> map (system:
					config.user
					|> lib.mapAttrs (name: module: let
						baseUsername = getUsername name;
						variant = name
							|> lib.removePrefix "${baseUsername}"
							|> lib.removePrefix "#"
						;
					in
					 	config.userAliases.${baseUsername}
						|> map (username: {
							"${username}#${variant}@${system}" = hmConfig {
								inherit system;
								module.imports = [
									module
									{
										home = {
											inherit username;
											sessionVariables.HOME_MANAGER_VARIANT = variant;
										};
									}
								];
							};
						})
					)
					|> lib.attrValues
				)
				|> lib.flatten
				|> lib.mergeAttrsList
			;
		};
	};
}
