{ pkgs, lib, config, ... }: {
	options.programs.telegram.enable = lib.mkEnableOption "Telegram";

	config = lib.mkIf config.programs.telegram.enable {
		home.packages = [
			pkgs.telegram-desktop
		];

		programs.hypr.windowRules = let
			inherit (config.programs.hypr) bttr;
		in [ {
			class = "org.telegram.desktop";
			cmd = (wid: "${bttr} move_to_workspace id ${wid} abs 1 special 1 || ${bttr} move_to_workspace id ${wid} abs 0 special 1");
		} ];
	};
}
