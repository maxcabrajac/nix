{ config, ...}: {
	programs.niri.settings.window-rules = [
		{
			matches = [{ app-id="steam_app_\\d+"; }];
			open-on-output = config.host.mainMonitor;
		}
	];
}
