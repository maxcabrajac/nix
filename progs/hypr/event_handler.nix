{ lib, config, pkgs, ...}: {
	options.programs.hypr = {
		onEvent = lib.mkOption {
			type = with lib.types; attrsOf (listOf str);
			default = {};
		};
	};

	config = let
		inherit (lib) pipe concatStringsSep attrsToList concatLines;
		processEvent = args: event: handlers: pipe handlers [
			(map (h: "${h} ${args}"))
			(concatStringsSep ";")
			(h: "${event}) ${h};;")
		];
		caseOptions = args: pipe config.programs.hypr.onEvent [
			attrsToList
			(map ({name, value}: processEvent args name value))
			concatLines
		];
		socat = lib.getExe pkgs.socat;
		getField = lib.getExe pkgs.getField;
		eventHandler = pkgs.writers.writeBashBin "hyprEventHandler" ''
			HYPRLAND_SOCK=''$XDG_RUNTIME_DIR/hypr/''$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock
			while read -r event_str; do
				event=''$(${getField} -d '>>' 1 <<< ''$event_str)
				args=''$(${getField} -d '>>' 2 <<< ''$event_str)
				if [ "''$1" = "-d" ]; then
					echo Event: \"''$event\" Args: \"''$args\"
				else
					case ''$event in
						${caseOptions ''"''$args"''}
					esac
				fi
			done < <(${socat} -U - UNIX-CONNECT:''$HYPRLAND_SOCK)
		'';
	in {
		home.packages = [ eventHandler ];

		wayland.windowManager.hyprland.settings = {
			exec-once = [ eventHandler ];
		};
	};
}
