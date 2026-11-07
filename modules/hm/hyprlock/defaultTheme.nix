{ lib, ... }: let
	d = lib.mkDefault;
in {
	hm.base.programs.hyprlock.settings = {
		background = {
			path = "screenshot";
			blur_passes = 2;
		};

		input-field = {
			placeholder_text = "";
			dots_center = d true;
			fade_on_empty = d true;
			shadow_passes = d 3;
			valign = d "center";
			halign = d "center";
		};
	};
}
