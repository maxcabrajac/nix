{ pkgs, lib, config, ...}: {
	options.profile.social = lib.mkEnableOption "Social profile";

	config = lib.mkIf config.profile.fonts {
		programs = {
			telegram.enable = true;
		};
	};
}
