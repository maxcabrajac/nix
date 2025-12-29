{ config, lib, util, inputs, ... }: {
	options = {
		dirs.modules = lib.mkOption {
			type = lib.types.path;
		};
	};

	config.flake = let
		getModulesFrom = subdir:
			util.allNixFiles (config.dirs.modules + "/${subdir}")
			|> map (path: {
				name = lib.removePrefix "${toString config.dirs.modules}/" (toString path);
				value = path;
			})
			|> lib.listToAttrs
		;
	in {
		nixosModules = getModulesFrom "nixos";
		# TODO: rename hm
		homeModules = getModulesFrom "hm";
	};
}
