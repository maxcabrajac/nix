{ config, lib, ... }: {
	programs.niri = {
		enable = true;
		settings = {
			input = {
				mouse = {
					accel-speed = -0.5;
				};
				keyboard = {
					xkb = {
						layout = "us";
						variant = "colemak";
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

			outputs = {
				"HDMI-A-1" = {
					mode = {
						height = 1080;
						width = 1920;
						refresh = 144.001;
					};

					position = {
						x = 0;
						y = 450;
					};
				};
				"DP-1" = {};
			};

			layout = let
				prop = x: { proportion = x; };
			in {
				gaps = 5;
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
					active.color = "#7fc8ff";
					inactive.color = "#505050";
				};
			};

			environment = {
				"ELECTRON_OZONE_HINT" = "wayland";
			};

			spawn-at-startup = [
				{ argv = [ "waybar" ]; }
			];

			prefer-no-csd = true;
			binds = with config.lib.niri.actions; {
				"XF86AudioRaiseVolume" = {
					action = spawn [ "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.025+" ];
					allow-when-locked = true;
				};

				"XF86AudioLowerVolume" = {
					action = spawn [ "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.025-" ];
					allow-when-locked = true;
				};

				"XF86AudioMute" = {
					action = spawn [ "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle" ];
					allow-when-locked = true;
				};

				"XF86AudioMicMute" = {
					action = spawn [ "wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle" ];
					allow-when-locked = true;
				};

				"Mod+Return".action = spawn "kitty";
				"Mod+Space".action = spawn "fuzzel";

				"Mod+M".action = close-window;

				"Mod+H".action = focus-column-left;
				"Mod+N".action = focus-window-down;
				"Mod+E".action = focus-window-up;
				"Mod+I".action = focus-column-right;

				"Mod+Alt+H".action = consume-or-expel-window-left;
				"Mod+Alt+N".action = move-window-down;
				"Mod+Alt+E".action = move-window-up;
				"Mod+Alt+I".action = consume-or-expel-window-right;
				"Mod+Ctrl+Alt+H".action = move-column-left;
				"Mod+Ctrl+Alt+I".action = move-column-right;

				"Mod+Shift+H".action = set-column-width "-5%";
				"Mod+Shift+N".action = set-window-height "+5%";
				"Mod+Shift+E".action = set-window-height "-5%";
				"Mod+Shift+I".action = set-column-width "+5%";

				"Mod+J".action = focus-monitor-left;
				"Mod+Y".action = focus-monitor-right;
				"Mod+Alt+J".action = move-column-to-monitor-left;
				"Mod+Alt+Y".action = move-column-to-monitor-right;

				"Mod+Z".action = maximize-column;
				"Mod+Alt+Z".action = fullscreen-window;
				"Mod+X".action = toggle-column-tabbed-display;

				"Mod+V".action = toggle-window-floating;
				"Mod+Shift+V".action = switch-focus-between-floating-and-tiling;
			};
		};
	};
}
