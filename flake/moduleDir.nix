{ config, lib, util, inputs, ... }: {
	options = {
		dirs.modules = lib.mkOption {
			type = lib.types.path;
		};
	};

	config.flake = let
		getModulesFrom = subdir:
			config.dirs.modules + "/${subdir}"
			|> util.readDirOpt { recursive = true; }
			|> lib.filter (f: f.parts.extension == "nix")
			|> map (f: {
				name = lib.removePrefix "${toString config.dirs.modules}/" (toString f.path);
				value = f.path;
			})
			|> lib.listToAttrs
		;
	in {
		nixosModules = getModulesFrom "nixos";
		homeModules = getModulesFrom "hm";
	};
}
