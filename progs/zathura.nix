{ ... }: {
	programs.zathura = {
		mappings = {
			"n" = "scroll down";
			"N" = "navigate next";
			"e" = "scroll up";
			"E" = "navigate previous";
			"i" = "scroll right";
			"h" = "scroll left";
			"u" = "zoom in";
			"y" = "zoom out";
			"k" = "search forward";
			"K" = "search backward";
		};

		options = {
			recolor = true;
			recolor-lightcolor = "#0f1419";
			recolor-darkcolor = "#ffffff";
			adjust-open = "width";
			guioptions = "";
		};
	};
}
