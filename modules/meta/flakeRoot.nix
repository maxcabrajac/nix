{ lib, ... }: {
	options.flakeRoot = lib.mkOption {
		type = lib.types.pathInStore;
	};
}
