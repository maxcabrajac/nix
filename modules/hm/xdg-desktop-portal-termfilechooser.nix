{ lib, config, pkgs, ...}: let
	cfg = config.xdg.portal.termfilechooser;
in {
	options.xdg.portal.termfilechooser = lib.mkOption {
		type = with lib.types; attrsOf attrs;
		default = {};
	};

	config = {
		xdg.portal = {
			extraPortals = lib.optional (cfg != {}) pkgs.xdg-desktop-portal-termfilechooser;
			config = cfg |> lib.mapAttrs (_: _: {
				"org.freedesktop.impl.portal.FileChooser" = [ "termfilechooser" ];
			});
		};

		xdg.configFile = let
			defaultConfig = {
				env = {
					TERMCMD = config.terminal.bin;
				};
			};
		in
			cfg
			|> lib.mapAttrs (_: userConfig: let
				config = lib.recursiveUpdate defaultConfig userConfig;
			in config // {
				env = config.env or {}
					|> lib.mapAttrs (name: value: "${name}=${value}")
					|> lib.attrValues
				;
			})
			|> lib.mapAttrs' (desktop: config: {
				name = "xdg-desktop-portal-termfilechooser/${desktop}";
				value.text = lib.generators.toINI { listsAsDuplicateKeys = true; } { filechooser = config; };
			});
	};
}
