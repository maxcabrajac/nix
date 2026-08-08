{ lib, ... }: {
	_module.args.mkModuleAttrsOption = {
		static ? {},
	}:
		lib.mkOption {
			type = lib.types.attrsOf <| lib.types.deferredModuleWith {
				staticModules = [static];
			};

			apply = lib.mapAttrs (key: module: {
				inherit key;
				imports = [ module ];
			});

			default = {};
		};
}
