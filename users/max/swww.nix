{ lib, pkgs, config, inputs, ... }: let
	cfg = config.services.swww;
	baseService = ["swww.service"];
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
						export SWWW_TRANSITION=any
						# this is dumb =P
						export SWWW_TRANSITOIN_FPS=120

						for MONITOR in $(swww query | cut -d: -f2); do
							SELECTED=$(shuf -n 1 ${wallpaperDrv})
							echo "[$MONITOR] = $SELECTED"
							swww img --outputs $MONITOR $SELECTED
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
