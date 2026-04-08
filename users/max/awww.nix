{ lib, pkgs, config, inputs, ... }: let
	cfg = config.services.awww;
	baseService = ["awww.service"];
	wallpaperDrv = inputs.wallpkgs.wallpapers
		|> lib.attrsets.collect (x: x ? path)
		|> map ({ path, ... }: path)
		|> lib.concatLines
		|> builtins.toFile "wallpaper-set"
	;
in
	lib.mkIf cfg.enable {
		systemd.user = {
			services.wallpaper-loop = {
				Unit = {
					Requires = baseService;
					After = baseService;
				};
				Service = {
					Type = "oneshot";
					ExecStart = pkgs.writeShellScript "wallpaper-loop" /* bash */ ''
						PATH=${pkgs.coreutils}/bin:${cfg.package}/bin
						export AWWW_TRANSITION=any
						# this is dumb =P
						export AWWW_TRANSITOIN_FPS=120

						for MONITOR in $(awww query | cut -d: -f2); do
							SELECTED=$(shuf -n 1 ${wallpaperDrv})
							echo "[$MONITOR] = $SELECTED"
							awww img --outputs $MONITOR $SELECTED
						done
					'';
				};
			};

			timers.wallpaper-loop = {
				Unit = {
					Requires = baseService;
					After = baseService;
				};
				Install = {
					WantedBy = baseService;
				};
				Timer = let
					period = "15min";
				in {
					OnBootSec = period;
					OnUnitActiveSec = period;
				};
			};
		};
	}
