{ lib, ... }: {
	hm.base = { config, ... }: let
		cfg = config.programs.lf;
	in {
		options.programs.lf = {
			useAsXdgPortal = lib.mkOption {
				type = lib.types.bool;
				default = true;
			};

			lfcd = lib.mkEnableOption "lfcd";
		};

		config = lib.mkIf cfg.enable {
			programs = let
				lf = lib.getExe cfg.package;
			in lib.mkIf cfg.lfcd {
				fish.shellAliases.lfcd = "cd (${lf} -print-last-dir)";
				bash.shellAliases.lfcd = "cd $(${lf} -print-last-dir)";
				zsh.shellAliases.lfcd = "cd $(${lf} -print-last-dir)";
			};

		};
	};
	hm.termfilechooser = { config, ... }: {
		xdg.portal.termfilechooser = lib.mkIf config.programs.lf.useAsXdgPortal {
			cmd = "lf-wrapper.sh";
		};
	};
}
