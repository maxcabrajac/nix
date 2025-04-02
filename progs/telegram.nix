{ pkgs, lib, config, ... }: {
	options.programs.telegram.enable = lib.mkEnableOption "Telegram";

	config = lib.mkIf config.programs.telegram.enable {
		home.packages = [
			pkgs.telegram-desktop
		];
	};
}
