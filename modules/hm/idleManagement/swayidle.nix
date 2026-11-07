{ lib, ... }: {
	hm.base = { config, ... }: let
		cfg = config.idleManagement;
	in {
		services.swayidle = {
			timeouts =
				cfg.timeouts
				|> lib.attrValues
				|> lib.filter (x: x.enable)
				|> map (x: {
					inherit (x) timeout;
					command = x.command or "";
					resumeCommand = x.resumeCommand or "";
				})
			;

			events = {
				lock = lib.mkIf (!isNull cfg.locker) cfg.locker;
				before-sleep = cfg.timeouts.lock.command;
			};
		};
	};
}
