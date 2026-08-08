{
	# TODO: Import hm lib into flake lib
	hm.base = { config, lib, ... }: let
		cfg = config.targets.genericLinux.gpu;
	in {
		options.targets.genericLinux.gpu.sudo = lib.mkOption {
			type = lib.types.str;
			default = "/bin/sudo";
		};

		config = lib.mkIf cfg.enable {
			# See https://github.com/nix-community/home-manager/blob/bf9ce9fec78f95f374e8dd3b503863a3ec128ebe/modules/targets/generic-linux/gpu/default.nix#L143-L156
			home.activation.checkExistingGpuDrivers = lib.mkForce <| lib.hm.dag.entryAfter ["writeBoundary"] ''
				existing=$(readlink /run/opengl-driver || true)
				new=${cfg.drivers}
				verboseEcho Existing drivers: ''${existing}
				verboseEcho New drivers: ''${new}
				if [[ -z "''${existing}" ]] || [[ "''${existing}" != "''${new}" ]] ; then
					echo Graphics driver update required. Running update with ${cfg.sudo}.
					$DRY_RUN_CMD ${cfg.sudo} ${lib.getExe cfg.setupPackage}
				fi
			'';
		};
	};
}
