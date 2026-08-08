{ config, lib, mkModuleAttrsOption, ... }: let
	moduleSystems = {
		os = {};
		hm = {};
		host = { imports = [ config.os.base ]; };
		user = { imports = [ config.hm.base ]; };
	};
in {
	imports = moduleSystems
		|> lib.mapAttrs (name: static: {
			options.${name} = mkModuleAttrsOption { inherit static; };
			config.flake.${name} = config.${name};
		})
		|> lib.attrValues;
	# Import into legacy build system
	config.flake = {
		nixosModules = config.os;
	};
}
