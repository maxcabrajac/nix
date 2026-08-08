{ lib, ... }: {
	hm.termfilechooser = { config, pkgs, ... }: let
		cfg = config.xdg.portal.termfilechooser;
	in {
		options.xdg.portal.termfilechooser = lib.mkOption {
			type = lib.types.attrs;
			default = {};
		};

		config = {
			# TODO: Add an assert for cfg != {}
			xdg.portal = {
				enable = true;
				extraPortals = [pkgs.xdg-desktop-portal-termfilechooser];
				config.common = {
					"org.freedesktop.impl.portal.FileChooser" = [ "termfilechooser" ];
				};
			};

			xdg.configFile = let
				defaultConfig = {
					env = {
						TERMCMD = config.terminal.bin;
					};
				};
			in
				cfg
				|> lib.recursiveUpdate defaultConfig
				|> (config: config // {
					env = config.env or {}
						|> lib.mapAttrs (name: value: "${name}=${value}")
						|> lib.attrValues
					;
				})
				|> (config: {
					"xdg-desktop-portal-termfilechooser/config".text = lib.generators.toINI { listsAsDuplicateKeys = true; } { filechooser = config; };
				});
		};
	};
}
