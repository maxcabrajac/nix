{ lib, config, ... }: {
	config = lib.mkIf config.programs.lf.enable {
		programs.fish.shellAliases.lfcd = "cd (lf -print-last-dir)";
		programs.bash.shellAliases.lfcd = "cd $(lf -print-last-dir)";
		programs.zsh.shellAliases.lfcd = "cd $(lf -print-last-dir)";
	};
}
