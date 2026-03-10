{ pkgs, lib, config, ... }: let
	cfg = config.programs.ripgrep;
	bins = pkgs |> lib.mapAttrs (_: p: lib.getExe p);
in {
	config = {
		programs.ripgrep = {
			enable = true;
			arguments = lib.flatten [
				"--smart-case"
				"--hidden"
				([
					"**/.git/*"
					"**/.jj/*"
					"*.lock"
					"*.tfstate"
				] |> map (x: "--glob=!${x}"))
			];
		};

		home.shellAliases = lib.mkIf cfg.enable {
			ggrep = bins.gnugrep;
			grep = bins.ripgrep;
		};
	};
}
