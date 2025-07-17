{ lib, util, config, ... }: let
	inherit (lib)
		map
		mkOption
		types
	;

	cfg = config.profiles;
in {
	options.profiles = {
		users = mkOption {
			type = with types; attrsOf <| listOf str;
			default = {};
			description = "List of activated profiles for each user";
		};

		users_by_profile = mkOption {
			type = with types; attrsOf <| listOf str;
			description = "List of activated profiles for each user";
		};

		forEachUser = mkOption {
			type = with types; functionTo <| functionTo anything;
		};
	};

	config.profiles = rec {
		users_by_profile =
			cfg.users
			|> lib.mapAttrs (user: map (profile: { inherit user profile; }))
			|> lib.attrValues
			|> lib.flatten
			|> lib.groupBy ({profile, ...}: profile)
			|>	lib.mapAttrs (_: map ({ user, ... }: user))
		;

		forEachUser = profileName: profileAttrs: {
			users = lib.genAttrs users_by_profile.${profileName} (_: profileAttrs);
		};
	};
}
