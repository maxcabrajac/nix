{ config, lib, util, ... }: let
	inherit (lib)
		attrNames
		mapAttrs
		listToAttrs
		filterAttrs
		mkOption
	;

	homes = util.readDir' ../../users
		|> map ({ name, file, ... }: {
			inherit name;
			value = { imports = util.readDir file; };
		})
		|> listToAttrs
	;

	contains = elem: list: builtins.any (e: e == elem) list;

	humans = config.users.humans;

	defaultHumanConfig = {
		isNormalUser = true;
		isSystemUser = false;
	};
in {
	options.users.humans = mkOption {
		type = with lib.types; attrsOf raw;
		default = {};
	};

	config = {
		users.users = humans |> mapAttrs (_: opts: opts // defaultHumanConfig);
		home-manager.users = homes |> filterAttrs (user: _: humans |> attrNames |> contains user);
	};
}
