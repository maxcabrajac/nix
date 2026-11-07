{ lib, ... }: let
	t = lib.types;
in {
	hm.base = { pkgs, config, ... }: let
		cfg = config.idleManagement;
	in {
		options.idleManagement = {
			timeouts = lib.mkOption {
				type = t.lazyAttrsOf <| t.submodule ({ config, ... }: {
					options = {
						enable = lib.mkEnableOption "" // {
							default = !(isNull config.command && isNull config.resumeCommand);
						};

						timeout = lib.mkOption {
							type = t.int;
						};

						command = lib.mkOption {
							type = t.nullOr t.str;
							default = null;
						};

						resumeCommand = lib.mkOption {
							type = t.nullOr t.str;
							default = null;
						};
					};
				});
			};

			locker = lib.mkOption {
				type = t.nullOr t.str;
				default = null;
			};
		};

		config.idleManagement.timeouts = let
			systemctl = lib.getExe' pkgs.systemd "systemctl";
			loginctl = lib.getExe' pkgs.systemd "loginctl";
		in {
			screenOff = {
				timeout = lib.mkDefault <| 5 * 60;
			};
			lock = {
				enable = lib.mkDefault <| !isNull cfg.locker;
				timeout = lib.mkDefault <| 8 * 60;
				command = "${loginctl} lock-session";
			};
			suspend-then-hibernate = {
				timeout = lib.mkDefault <| 15 * 60;
				command = "${systemctl} suspend-then-hibernate";
			};
		};
	};
}
