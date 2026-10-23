{
	user.helo = {
		programs.waybar = {
			enable = true;
			systemd.enable = true;

			settings.mainbar = {
				layer = "top";
				position = "top";
				height = 30;

				# TODO: Use osConfig.monitors
				output = [ "eDP-1" "DP-1" ];
				# TODO: hardcoded :shrug:
				modules-left = [ "niri/workspaces" "niri/windows" ];
				modules-center = [ "clock" ];
				modules-right = [ "wireplumber" "backlight" "battery" "tray" ];
			};
		};
		stylix.targets.waybar = {
			enableLeftBackColors = true;
			enableRightBackColors = true;
		};
	};
}
