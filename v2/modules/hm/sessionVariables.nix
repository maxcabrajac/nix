{ config, ... }: {
	systemd.user.sessionVariables = config.home.sessionVariables;
}
