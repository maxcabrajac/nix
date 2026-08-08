{ inputs, lib, config, pkgs, ... }: let
	mabar = inputs.mabar.packages.${pkgs.stdenv.hostPlatform.system}.mabar;
	cfg = config.programs.niri.mabar;
	ifNiri = lib.mkIf config.programs.niri.enable;
in {
	options.programs.niri.mabar = with lib.types; {
		package = lib.mkOption {
			type = package;
			default = mabar;
		};

		finalPackage = lib.mkOption {
			type = package;
		};

		overrides = lib.mkOption {
			type = attrsOf raw;
		};

		wmInterface = let
			funcs = [
				"workspaces"
				"windows"
			];
			funcOption = _: {
				init = lib.mkOption {
					type = str;
					default = "";
				};
				on = lib.mkOption {
					type = listOf str;
				};
				run = lib.mkOption {
					type = str;
				};
			};
		in
			lib.genAttrs funcs funcOption
		;
	};

	config = {
		home.packages = ifNiri [
			cfg.overrides.wmInterface
			cfg.finalPackage
		];

		programs.niri.mabar = {
			wmInterface = let
				jq = "jq -c";
				niriMsg = "niri msg -j";
			in {
				windows = {
					init = "monitor=$1";
					on = [
						"WindowFocusChanged"
						"WindowOpenedOrChanged"
						"WindowLayoutsChanged"
					];
					run = /* bash */ ''
						workspace=$(${niriMsg} workspaces | ${jq} --arg monitor "$monitor" '
							.[] | select(.output == $monitor and .is_active).id
						')
						if [ -z "$workspace" ]; then
							echo "[]"
							return
						fi
						${niriMsg} windows | ${jq} --arg workspace "$workspace" '
							map(select(.workspace_id == ($workspace | tonumber) and .is_floating == false)
								| {
									class: .app_id,
									focused: .is_focused,
									x: .layout.pos_in_scrolling_layout[0] - 1,
									y: .layout.pos_in_scrolling_layout[1] - 1,
								}
							)
						'
					'';
				};
			};

			overrides.wmInterface = let
				buildFunc = name: { init, on, run }: let
					onEvent = ''niri msg -j event-stream | jq -c -r --unbuffered 'select(${on |> map (x: ".${x} // ") |> lib.concatStrings} empty) | keys | .[]' '';
				in /* bash */ ''
					${name}() {

						${init}

						onEvent() {
							${run}
						}

						onEvent
						${onEvent} | while read -r event; do
							echo "Received event: $event" >&2
							onEvent
						done
					}
				'';
				funcs = cfg.wmInterface
					|> lib.mapAttrs buildFunc
					|> lib.attrValues
					|> lib.concatLines
				;

				bins = with pkgs; [
					coreutils
					jq
					niri
				];

				mainBody = ''
					export PATH=${lib.makeBinPath bins}

					${funcs}
					"$@"
				'';
			in
				pkgs.writeShellScriptBin "wmInterface" mainBody
			;

			finalPackage = (cfg.package.override cfg.overrides);
		};

		systemd.user.services.mabar = ifNiri {
			Unit = {
				Description = "My graphical app";
				After = [ "graphical-session.target" ];
				PartOf = [ "graphical-session.target" ];
			};

			Service = {
				ExecStart = lib.getExe cfg.finalPackage;
				Restart = "on-failure";
			};

			Install = {
				WantedBy = [ "graphical-session.target" ];
			};
		};
	};
}
