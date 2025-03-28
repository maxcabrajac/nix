{ lib, config, ... }: {
	config.programs = lib.mkIf config.profile.terminal {
		fish.functions.mkcd = {
			body = "mkdir -p $argv && cd $argv";
		};
	};
}
