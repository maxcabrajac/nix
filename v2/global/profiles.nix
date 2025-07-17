{ lib, util, config, ... }: let
	inherit (lib)
		mkOption
		types
		map
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
	};

	config = {
		profiles.users_by_profile =
			cfg.users
			|> lib.mapAttrs (user: map (profile: { inherit user profile; }))
			|> lib.attrValues
			|> lib.flatten
			|> lib.groupBy ({profile, ...}: profile)
			|>	lib.mapAttrs (_: map ({ user, ... }: user))
		;
	};
}
