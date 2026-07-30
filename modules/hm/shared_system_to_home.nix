{ lib, util, ... }: {
	options.host = lib.mkOption {
		type = lib.types.submodule {
			imports =
				util.allNixFiles ../shared_system_to_home
				|> map (m: import m "hm")
			;

			config._module.args = {
				inherit lib;
			};
		};
	};
}
