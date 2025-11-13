{ pkgs, lib, config, ... }: let
	cfg = config.programs.niri;
	libNiri = config.lib.niri;
	keys = [
		"A" "R" "S" "T" "D" # homerow
		"Q" "W" "F" "P" "G" # top row
	];
	keysLayout = [
		["Q" "W" "F" "P" "G"] # top row
		["A" "R" "S" "T" "D"] # homerow
	];

	padNumber = x: n: let
		s = toString n;
		pad = lib.concatStringsSep "" (lib.genList (_: "0") (x - lib.stringLength s));
	in
		pad + s
	;

	monitors = cfg.settings.outputs |> lib.attrNames;
	bins = pkgs |> lib.mapAttrs (_: p: lib.getExe p);
	niri = lib.getExe cfg.package;
in {
	programs.niri = {
		settings = {
			workspaces = lib.cartesianProduct { key = keys; monitor = monitors; }
				|> lib.imap (i: { key, monitor }: {
					name = "${padNumber 5 i}";
					value = {
						name = "${monitor}_${key}";
						open-on-output = monitor;
					};
				})
				|> lib.listToAttrs
			;

			binds = let
				inherit (bins) jq;
				metaAction = action: key:
					pkgs.writers.writeDash "per_monitor_${action}" ''
						focused=$(${niri} msg -j focused-output | ${jq} -r '.name')
						${niri} msg action ${action} "''${focused}_$1"
					''
					|> (script: {
						action = libNiri.actions.spawn [ (toString script) key ];
						hotkey-overlay.hidden = true;
					})
				;

				focus = metaAction "focus-workspace";
				move = metaAction "move-window-to-workspace";
			in
				keys
				|> map (key: {
					"Mod+${key}" = focus key;
					"Mod+Alt+${key}" = move key;
				})
				|> lib.fold (x: y: x // y) {}
			;

			# Aesthetic changes
			animations.workspace-switch.enable = false;
		};

		mabar.wmInterface.workspaces = let
			# compact jq
			jq = "jq -c";
			niriMsg = "niri msg -j";
			newlySelectedWorkspaceId = /* bash */ "${niriMsg} event-stream | ${jq} -r --unbuffered '.WorkspaceActivated // empty | .id'";
			setMonitorData = /* bash */ ''
				monitorData=$(${niriMsg} workspaces | ${jq} --arg monitor "$monitor" '
					map(
						select(.output == $monitor)
						| {
							name: .name // empty | sub("\($monitor)_"; ""),
							value: {
								id: .id,
								focused: .is_active,
								empty: .active_window_id == null
							}
						}
					) | from_entries
				')
			'';
			printLayout = /* bash */ ''
				echo '${builtins.toJSON keysLayout}' | ${jq} --argjson mData "$monitorData" 'map(map($mData.[.]))'
			'';
			eventProcessor = /* bash */ ''\
				while read -r selectedId; do
					${setMonitorData}

					if $(echo $monitorData | ${jq} --argjson id "$selectedId" 'to_entries | map(.value.id) | contains([$id])'); then
						${printLayout}
					fi
				done
			'';
		in /* bash */ ''
			export PATH=${pkgs.coreutils}/bin:${pkgs.jq}/bin:${pkgs.niri}/bin

			monitor=$1
			while [ -z "$monitorData" ] || $(echo $monitorData | ${jq} 'any(.focused) | not'); do
				${setMonitorData}
			done
			${printLayout}
			${newlySelectedWorkspaceId} | ${eventProcessor}
		'';
	};
}
