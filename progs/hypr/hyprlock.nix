{ pkgs, lib, config, ...}: {
	programs.hyprlock = {
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
}
