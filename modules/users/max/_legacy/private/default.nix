{ config, ... }: {
	secretFiles = {
		scripts = {
			src = ./scripts.fish;
			dest = "${config.xdg.configHome}/fish/conf.d/private_scripts.fish";
		};
	};
}
