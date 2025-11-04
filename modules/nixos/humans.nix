{ config, lib, util, ... }: let
	inherit (lib)
		attrNames
		mapAttrs
		listToAttrs
		filterAttrs
		mkOption
	;

	homes = util.readDir ../../users
		|> map ({ name, path, ... }: let
			homeRoot = path;
		in {
			inherit name;
			value = {
				imports =
					homeRoot
					|> util.readDirOpt { recursive = true; }
					|> map (f: f.path)
				;
			};
		})
		|> listToAttrs
	;

	contains = elem: list: builtins.any (e: e == elem) list;

	humans = config.humans;

	defaultHumanConfig = {
		isNormalUser = true;
		isSystemUser = false;
	};
in {
	options = {
		humans = mkOption {
			type = with lib.types; attrsOf raw;
			default = {};
		};
	};

	config = {
		users.users = humans |> mapAttrs (_: opts: opts // defaultHumanConfig);
		home-manager.users = homes |> filterAttrs (user: _: humans |> attrNames |> contains user);

		lib.humans.hmConfigs = humans |> attrNames |> map (name: config.home-manager.users.${name});
	};
}
