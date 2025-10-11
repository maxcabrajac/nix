{ pkgs, lib, config, ... }: let
	cfg = config.programs.niri;
	libNiri = config.lib.niri;
	keys = [
		"A" "R" "S" "T" "D" # homerow
		"Q" "W" "F" "P" "G" # top row
	];

	padNumber = x: n: let
		s = toString n;
		pad = lib.concatStringsSep "" (lib.genList (_: "0") (x - lib.stringLength s));
	in
		pad + s
	;

	monitors = cfg.settings.outputs |> lib.attrNames;
in {
	programs.niri.settings = {
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
			bins = pkgs |> lib.mapAttrs (name: p: lib.getExe p);
			inherit (bins) niri jq;

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
}
