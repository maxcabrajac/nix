{ lib, config, ... }: {
	options = {
		hmExport = lib.mkOption {
			type = with lib.types; attrsOf <| submodule ({ config, ... }: {
				options = {
					from = lib.mkOption {
						type = listOf str;
					};

					create = lib.mkOption {
						type = bool;
						default = false;
					};

					option = lib.mkOption {
						type = raw;
						defaultText = "mkOption { type = raw }";
						default = lib.mkOption {
							type = raw;
						};
					};
				};
			});
			default = {};
		};

		hmExported = lib.mkOption {
			type = with lib.types; attrsOf raw;
			readOnly = true;
		};
	};

	config = {
		home-manager.sharedModules = config.hmExport
			|> lib.attrValues
			|> lib.filter (x: x.create)
			|> map ({ from, option, ... }: { options = lib.setAttrByPath from option; })
		;

		hmExported = config.hmExport
			|> lib.mapAttrs (_: { from, ... }:
				config.lib.humans.hmConfigs
				|> lib.filter (lib.hasAttrByPath from)
				|> lib.map (lib.attrByPath from null)
				|> lib.mkMerge
			)
		;
	};
}
