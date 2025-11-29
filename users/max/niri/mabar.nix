{ inputs, lib, config, pkgs, ... }: let
	mabar = inputs.mabar.packages.${pkgs.stdenv.hostPlatform.system}.mabar;
	cfg = config.programs.niri.mabar;
	ifNiri = lib.mkIf config.programs.niri.enable;
in {
	options.programs.niri.mabar = with lib.types; {
		package = lib.mkOption {
			type = package;
			default = mabar;
		};

		finalPackage = lib.mkOption {
			type = package;
		};

		overrides = lib.mkOption {
			type = attrsOf raw;
		};

		wmInterface = let
			funcs = [ "workspaces" ];
			funcOption = _: lib.mkOption {
				type = str;
			};
		in
			lib.genAttrs funcs funcOption
		;
	};

	config = {
		home.packages = ifNiri [
			cfg.overrides.wmInterface
			cfg.finalPackage
		];

		programs.niri.mabar = {
			overrides.wmInterface = let
				funcs = cfg.wmInterface
					|> lib.mapAttrs (name: body: ''
							${name}() {
								${body}
							}
						'')
					|> lib.attrValues
					|> lib.concatLines
				;
				mainBody = ''
					${funcs}
					"$@"
				'';
			in
				pkgs.writeShellScriptBin "wmInterface" mainBody
			;

			finalPackage = (cfg.package.override cfg.overrides);
		};

		systemd.user.services.mabar = ifNiri {
			Unit = {
				Description = "My graphical app";
				After = [ "graphical-session.target" ];
				PartOf = [ "graphical-session.target" ];
			};

			Service = {
				ExecStart = lib.getExe cfg.finalPackage;
				Restart = "on-failure";
			};

			Install = {
				WantedBy = [ "graphical-session.target" ];
			};
		};
	};
}
