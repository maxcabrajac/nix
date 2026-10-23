{ lib, ... }: {
	hm.base = { pkgs, config, ... }: let
		awwwCfg = config.services.awww;
		cfg = awwwCfg.rngLoop;
	in {
		options.services.awww.rngLoop = {
			enable = lib.mkEnableOption "" // {
				default = (cfg.dir or "") != "";
			};
			dir = lib.mkOption {
				type = with lib.types; either path str;
			};
			fps = lib.mkOption {
				type = lib.types.int;
				default = 60;
			};
			transition = lib.mkOption {
				type = lib.types.str;
				default = "any";
			};
			period = lib.mkOption {
				type = lib.types.str;
				default = "1h";
			};
		};

		config = lib.mkIf (awwwCfg.enable && cfg.enable) (let
			baseService = ["awww.service"];
		in {
			systemd.user = {
				services.awwwRngLoop = {
					Unit = {
						Requires = baseService;
						After = baseService;
					};
					Service = {
						Type = "oneshot";
						ExecStart = pkgs.writeShellScript "awwwRngLoop" /* bash */ ''
							PATH=${lib.makeBinPath [ pkgs.coreutils pkgs.findutils awwwCfg.package]}
							export AWWW_TRANSITION="${cfg.transition}"
							export AWWW_TRANSITOIN_FPS=${toString cfg.fps}

							for MONITOR in $(awww query | cut -d: -f2); do
								SELECTED=$(find ${cfg.dir} | shuf -n 1)
								echo "[$MONITOR] = $SELECTED"
								awww img --outputs $MONITOR $SELECTED
							done
						'';
					};
				};

				timers.awwwRngLoop = {
					Unit = {
						Requires = baseService;
						After = baseService;
					};
					Install = {
						WantedBy = baseService;
					};
					Timer = {
						OnBootSec = cfg.period;
						OnUnitActiveSec = cfg.period;
					};
				};
			};
		});
	};
}
