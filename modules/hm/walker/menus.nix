{ lib, ... }: {
	hm.base = { config, pkgs, ... }: let
		opt = type: default: lib.mkOption {
			inherit type default;
		};
		inherit (lib.types)
			bool
			str
			listOf
			luaInline
			attrsOf
			anything
		;
	in {
		options.programs.elephant.menus = lib.mkOption {
			type = lib.types.attrsOf <| lib.types.submodule ({ name, config, ... }: {
				freeformType = attrsOf anything;
				options = {
					Name = opt str name;
					NamePretty = opt str config.Name;
					Cache = opt bool false;
					Action = opt str ''${pkgs.libnotify}/bin/notify-send ${config.Name} %VALUE%'' // {
						exampleText = "notify-send <name>: %VALUE%";
					};
					HideFromProviderList = opt bool false;
					SearchName = opt bool false;
					SearchPriority = opt (listOf str) [ "text" "keywords" ];
					GetEntries = lib.mkOption {
						type = luaInline;
					};
				};
			});
		};

		config.programs.elephant.provider.menus.lua =
			config.programs.elephant.menus
			|> lib.mapAttrs (_: lib.generators.toLua { asBindings = true; })
		;
	};
}
