{ lib, config, ... }: let
	cfg = config.terminal;
in {
	options.terminal = {
		enable = lib.mkEnableOption "" // {
			default = config.profiles.gui;
		};

		package = lib.mkOption {
			type = with lib.types; package;
		};

		desktopFile = lib.mkOption {
			type = lib.types.pathInStore;
			default = cfg.package
				|> (p: "${p}/share/applications/${p.pname}.desktop")
			;
		};

		bin = lib.mkOption {
			type = lib.types.str;
		};
	};

	config = lib.mkMerge [
		{
			terminal.bin = lib.getExe cfg.package;
		}
		(lib.mkIf cfg.enable {
			home = {
				packages = [ cfg.package ];
			};

			assertions = [
				{
					assertion = builtins.pathExists cfg.desktopFile;
					message = "terminal.desktopFile does not exist";
				}
			];
			xdg.terminal-exec = {
				enable = true;
				settings = {
					default = [
						cfg.desktopFile
					];
				};
			};
		})
	];
}
