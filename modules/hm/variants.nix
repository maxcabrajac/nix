{ lib, ... }: {
	options = {
		variant = lib.mkOption {
			type = lib.types.enum [ "default" ];
			default = "default";
		};
	};
}
