{ pkgs, lib, config, ...}: let
	enable = config.programs.hypr.enable;
in {
	programs.hyprlock = {
		inherit enable;
		settings = {
			background = {
				path = "screenshot";
				blur_passes = 4;
				blur_size = 1;
			};

			input-field = {
				size = "10%, 5%";
				dots_center = true;
				fade_on_empty = true;
				hide_input = false;
				placeholder_text = "";
			};
		};
	};

	services.hypridle = {
		inherit enable;
		settings = let
			lock = "loginctl lock-session";
			screen = v: let
				state = if v then "on" else "off";
			in "hyprctl dispatch dpms ${state}";
			on = true;
			off = false;
		in {
			general = {
				lock_cmd = "pidof hyprlock || hyprlock";
				before_sleep_cmd = lock;
				after_sleep_cmd = "hyprclt dispacth dpms on";
			};

			listener = let min = 60; in [
				{
					timeout = 5 * min;
					on-timeout = lock;
				}

				{
					timeout = 6 * min;
					on-timeout = screen off;
					on-resume = screen on;
				}
			];
		};
	};
}
