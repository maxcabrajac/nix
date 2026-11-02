{ lib, ... }: let
	t = lib.types;
in {
	packages.os = {
		writeShellApplication,
		coreutils,
		nh,
	}:
		writeShellApplication {
			name = "os";
			runtimeInputs = [ coreutils nh ];
			text = builtins.readFile ./main.sh;
		};

	os.base = { config, pkgs, withSystem, ... }: let
		cfg = config.services.systemUpgrader;
	in {
		options.services.systemUpgrader = {
			package = lib.mkOption {
				type = t.package;
				default = withSystem.packages.os;
			};
			# TODO: write updater service
			enable = lib.mkOption {
				type = t.bool;
				default = false;
			};
			install = lib.mkOption {
				type = t.bool;
				default = cfg.enable;
			};
			flake = lib.mkOption {
				type = t.str;
				default = "";
			};
			finalPackage = lib.mkOption {
				type = t.package;
				# TODO: Add a helper for this
				default = pkgs.writeShellScriptBin "os" ''exec ${lib.getExe cfg.package} --flake "${cfg.flake}" "$@"'';
			};
		};

		config = lib.mkMerge [
			{
				assertions = [{
					assertion = (cfg.enable || cfg.install) -> config.security.sudo.enable;
					message = "services.systemUpgrader requires security.sudo.enable";
				}];
			}
			(lib.mkIf cfg.install {
				environment.systemPackages = [ cfg.finalPackage ];
			})
			(lib.mkIf cfg.enable {
				systemd = {
					services.systemUpgrader = {
						script = "${lib.getExe cfg.finalPackage} boot --yes --slow --no-recreate-entry --no-pretty";
						startAt = "daily";
						wants = [ "network-online.target" ];
						after = [ "network-online.target" ];
						serviceConfig.Type = "oneshot";
						path = [ config.nix.package ];
					};
					timers.systemUpgrader.timerConfig.Persistent = "true";
				};
			})
		];
	};
}
