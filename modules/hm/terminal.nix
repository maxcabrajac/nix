{ lib, ... }: {
	# TODO: ponder on this module. I feel weird about it
	hm.base = { config, ... }: let
		cfg = config.terminal;
	in {
		options.terminal = {
			enable = lib.mkEnableOption "";

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
				default = lib.getExe cfg.package;
			};
		};

		config = lib.mkIf cfg.enable {
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
		};
	};
}
