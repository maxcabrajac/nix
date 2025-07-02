{ lib, config, ... }: let
	inherit (lib) mkOption types pipe flip attrsToList concatStringsSep;
	cfg = config.programs.fish;
in {
	options.programs.fish = {
		sessionVariables = mkOption {
        default = { };
        type =
          with types;
          lazyAttrsOf (oneOf [
            str
            int
            path
          ]);
      };
	};

	config = {
		programs.fish.interactiveShellInit = pipe cfg.sessionVariables [
			attrsToList
			(map ({ name, value }: ''set -x "${name}" ${value}''))
			(concatStringsSep "\n")
		];
	};
}
