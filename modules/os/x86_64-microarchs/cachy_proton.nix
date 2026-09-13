{ inputs, lib, ... }: {
	# Make non-steam launchers inherit protons
	hm.base = inputs.nix-gaming-edge.homeModules.steam-compat-tools;

	os.x86_64 = { config, ... }: {
		options.cachyProton = {
			enable = lib.mkEnableOption "" // {
				default = true;
			};
			microarch = lib.mkOption {
				type = lib.types.str;
				default = config.hardware.cpu.x86.microarch;
			};
		};

		config.programs.steam.extraCompatPackages = let
			cfg = config.cachyProton;
			name = "proton-cachyos" + (lib.optionalString (cfg.microarch == "x86-64-v3") "-x86_64-v3");
		in lib.mkIf cfg.enable [
			inputs.nix-gaming-edge.packages.x86_64-linux.${name}
		];
	};
}
