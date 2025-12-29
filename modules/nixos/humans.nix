{ config, lib, util, ... }: let
	inherit (lib)
		attrNames
		mapAttrs
		listToAttrs
		filterAttrs
		mkOption
	;

	homes = util.readDir ../../users
		|> map ({ name, path, ... }: {
			inherit name;
			value.imports = util.allNixFiles path;
		})
		|> listToAttrs
	;

	humans = config.humans;
in {
	options = {
		humans = mkOption {
			type = with lib.types; attrsOf (submodule {
				options = {
					os = mkOption {
						type = raw;
						default = {};
					};

					hm = {
						enable = mkOption {
							type = bool;
							default = true;
						};

						from = mkOption {
							type = nullOr str;
							default = null;
						};

						extraConfigs = mkOption {
							type = raw;
							default = {};
						};
					};
				};
			});
			default = {};
		};
	};

	config = {
		users.users = humans |> mapAttrs (_: h: {
			isNormalUser = true;
			isSystemUser = false;
		} // h.os);

		home-manager.users = humans
			|> filterAttrs (_: h: h.hm.enable)
			|> mapAttrs (name: h: {
				imports = [
					h.hm.extraConfigs
					homes.${if isNull h.hm.from then name else h.hm.from}
				];
			});

		lib.humans.hmConfigs = humans |> attrNames |> map (name: config.home-manager.users.${name});
	};
}
