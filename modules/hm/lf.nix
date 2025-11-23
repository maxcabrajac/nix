{ lib, config, ... }: let
	cfg = config.programs.lf;
in {
	options.programs.lf = {
		useAsXdgPortalOn = lib.mkOption {
			type = with lib.types; attrsOf bool;
			default = {};
		};
	};

	config = lib.mkIf cfg.enable {
		programs = let
			lf = lib.getExe cfg.package;
		in {
			fish.shellAliases.lfcd = "cd (${lf} -print-last-dir)";
			bash.shellAliases.lfcd = "cd $(${lf} -print-last-dir)";
			zsh.shellAliases.lfcd = "cd $(${lf} -print-last-dir)";
		};

		xdg.portal.termfilechooser = cfg.useAsXdgPortalOn |> lib.mapAttrs (_: enable: lib.mkIf enable {
			cmd = "lf-wrapper.sh";
		});
	};
}
