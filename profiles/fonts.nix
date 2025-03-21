{ pkgs, lib, config, ...}: {

	options.profile.fonts = lib.mkEnableOption "Fonts Profile";

	config = lib.mkIf config.profile.fonts {
		fonts.fontconfig.enable = true;
		home = {
			packages = with pkgs; [
				fira-code
				nerd-fonts.symbols-only
			];
		};
	};
}
