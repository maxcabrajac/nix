{
	user.helo = { config, ... }: let
		inherit (config.lib.stylix) colors;
	in {
		programs.niri = {
			enable = true;
			settings = {
				input = {
					keyboard = {
						xkb = {
							layout = "us";
						};
						numlock = true;
					};
					warp-mouse-to-focus = {
						enable = true;
						mode = "center-xy-always";
					};
					focus-follows-mouse = {
						enable = true;
						max-scroll-amount = "0%";
					};
				};

				layout = let
					prop = x: { proportion = x; };
				in {
					gaps = 10;
					center-focused-column = "on-overflow";

					preset-column-widths = map prop [
						0.33333
						0.5
						0.66667
						1.0
					];

					default-column-width = prop 0.5;

					focus-ring = {
						width = 2;
						active.color = colors.withHashtag.base0D;
						inactive.color = colors.withHashtag.base03;
					};
				};

				environment = {
					"ELECTRON_OZONE_HINT" = "wayland";
				};

				prefer-no-csd = true;
				binds = {
					# TODO: move this to global
					"XF86AudioRaiseVolume" = {
						action.spawn = [ "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.025+" ];
						allow-when-locked = true;
					};

					"XF86AudioLowerVolume" = {
						action.spawn = [ "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.025-" ];
						allow-when-locked = true;
					};

					"XF86AudioMute" = {
						action.spawn = [ "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle" ];
						allow-when-locked = true;
					};

					"XF86AudioMicMute" = {
						action.spawn = [ "wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle" ];
						allow-when-locked = true;
					};

					"Mod+M".action.close-window = {};

					"Mod+H".action.focus-column-left = {};
					"Mod+J".action.focus-window-down = {};
					"Mod+K".action.focus-window-up = {};
					"Mod+L".action.focus-column-right = {};

					"Mod+Alt+H".action.consume-or-expel-window-left = {};
					"Mod+Alt+J".action.move-window-down = {};
					"Mod+Alt+K".action.move-window-up = {};
					"Mod+Alt+L".action.consume-or-expel-window-right = {};
					"Mod+Ctrl+Alt+H".action.move-column-left = {};
					"Mod+Ctrl+Alt+L".action.move-column-right = {};

					"Mod+Shift+H".action.set-column-width = "-5%";
					"Mod+Shift+J".action.set-window-height = "+5%";
					"Mod+Shift+K".action.set-window-height = "-5%";
					"Mod+Shift+L".action.set-column-width = "+5%";

					"Mod+Y".action.focus-monitor-left = {};
					"Mod+U".action.focus-workspace-down = {};
					"Mod+I".action.focus-workspace-up = {};
					"Mod+O".action.focus-monitor-right = {};
					"Mod+Alt+Y".action.move-column-to-monitor-left = {};
					"Mod+Alt+U".action.move-column-to-workspace-down = {};
					"Mod+Alt+I".action.move-column-to-workspace-up = {};
					"Mod+Alt+O".action.move-column-to-monitor-right = {};

					"Mod+Z".action.maximize-column = {};
					"Mod+Alt+Z".action.fullscreen-window = {};

					"Mod+F".action.toggle-window-floating = {};
					"Mod+Shift+F".action.switch-focus-between-floating-and-tiling = {};

					"Print".action.screenshot = {};
				};
			};
		};
	};
}
