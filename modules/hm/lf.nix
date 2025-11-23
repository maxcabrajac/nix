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
		programs.fish.shellAliases.lfcd = "cd (${cfg.package} -print-last-dir)";
		programs.bash.shellAliases.lfcd = "cd $(${cfg.package} -print-last-dir)";
		programs.zsh.shellAliases.lfcd = "cd $(${cfg.package} -print-last-dir)";

		xdg.portal.termfilechooser = cfg.useAsXdgPortalOn |> lib.mapAttrs (_: enable: lib.mkIf enable {
			cmd = "lf-wrapper.sh";
		});
	};
}
