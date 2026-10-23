{ lib, osConfig, ...}: {
	programs.niri.settings.window-rules = [
		(lib.mkIf (osConfig != null) {
			matches = [{ app-id="steam_app_\\d+"; }];
			open-on-output = osConfig.mainMonitor;
		})
	];
}
