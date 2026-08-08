{ lib, config, ... }: let
	moduleSystems = [
		"os"
		"hm"
		"host"
		"user"
	];
in {
	imports = moduleSystems
		|> map (name: {
			options.${name} = lib.mkOption {
				type = lib.types.attrsOf lib.types.deferredModule;
				default = {};
			};
			config.flake.${name} = config.${name};
		});
	# Import into legacy build system
	config.flake = {
		nixosModules = config.os;
		homeModules = config.hm;
	};
}
