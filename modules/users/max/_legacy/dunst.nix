{ config, ... }: {
	services.dunst = {
		enable = config.profiles.gui;
	};
}
