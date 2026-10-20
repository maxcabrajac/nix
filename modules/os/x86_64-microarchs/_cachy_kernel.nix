{ inputs, lib, ... }: {
	os.x86_64 = { config, pkgs, ... }: let
		cfg = config.cachyKernel;
		boolOpt = default: lib.mkEnableOption "" // { inherit default; };
	in {
		options.cachyKernel = {
			enable = boolOpt pkgs.stdenv.hostPlatform.isx86_64;
			useLatest = boolOpt true;
			useBORE = boolOpt cfg.useLatest;
			useLTO = boolOpt true;
			microarch = lib.mkOption {
				type = lib.types.str;
				default = config.hardware.cpu.x86.microarch;
			};
		};

		config = {
			assertions = [
				{
					assertion = cfg.useBORE -> cfg.useLatest;
					message = "cachyKernel's BORE scheduler requires using latest.\nSet cachyKernel.useLatest or cachyKernel.useBORE accordingly";
				}
			];
			boot.kernelPackages = let
				version = if cfg.useLatest
					then
						if cfg.useBORE
						then "bore"
						else "latest"
					else "lts"
				;
				lto = lib.optionalString cfg.useLTO "-lto";
				microarch = cfg.microarch
					|> lib.replaceString "x86-64" "x86_64"
					|> (x: lib.optionalString (x != "x86_64") "-${x}")
				;
				name = "linuxPackages-cachyos-${version}${lto}${microarch}";
			in
				inputs.cachy-kernel.legacyPackages.x86_64-linux.${name};
		};
	};
}
