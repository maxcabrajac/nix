{ config, ... }: {
	programs.dmenu_scripts = {
		search.engines = config.web.sites;
	};
}
