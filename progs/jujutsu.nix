{ lib, config, pkgs, ... }: let
	inherit (lib) mkOption types mkIf getExe;
	cfg = config.programs.jujutsu;
in {
	options.programs.jujutsu = {
		bypass.enableFishIntegration = mkOption {
			type = types.bool;
			default = config.home.shell.enableFishIntegration;
		};

		# TODO: generate completions for the used shells
		# TODO: use this variable to decide whether to use dynamic completions
		useDynamicCompletions = mkOption {
			type = types.bool;
			default = true;
		};
	};

	config = {
	};
}
