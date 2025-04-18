{ lib, ... }: {
	options.programs.eww = {
		widgets = lib.mkOption {
			type = with lib.types; let
				widget = submodule {
					args = lib.mkOption {
						type = str;
					};

					def = lib.mkOption {
						type = str;
					};

					use = lib.mkOption {
						type = listOf str;
					};
				};
			in attrsOf widget;
		};

		windows = lib.mkOption {
			type = with lib.types; let
				window = submodule {
					params = lib.mkOption {
						type = attrsOf str;
					};
					def = lib.mkOption {
						type = str;
					};
					uses = lib.mkOption {
						type = listOf str;
					};
				};
			in attrsOf window;
		};

		rawYuck = lib.mkOption {
			type = with lib.types; listOf str;
			default = [];
		};
	};

	config.programs.eww = {
		rawYuck = lib.optional true /*yuck*/ ''

			;;;
			;;; Helpers
			;;;

			(defvar module_spacing 5)
			(include "lib.yuck")
			(include "globals.yuck")
			(include "./modules")

			;;;
			;;; Layout
			;;;

			(defwidget tray []
				(box
					:class "tray"
					:space-evenly false
					:halign "end"
					:spacing {module_spacing}
					(volume)
					(wifi)
					(cpu)
					(battery :battery "BAT0")
					(dnd)
					(systray
						:spacing 5
						:icon-size 20
						:prepend-new false
					)
				)
			)

			(defwidget bar [monitor]
				(centerbox
					:orientation "h"
					(workspaces :monitor {monitor})
					(clock)
					(tray)
   			)
			)

			(defwindow bar [screen]
				:windowtype "dock"
				:geometry (geometry
					:x "0%"
					:y "0%"
					:width "99%"
					:height "10px"
					:anchor "top center"
				)
				:reserve (struts :side "top" :distance "4%")
				:exclusive true
				(bar :monitor {screen})
			)

		'';

	};
}
