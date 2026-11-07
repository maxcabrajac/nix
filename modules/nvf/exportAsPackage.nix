{ config, lib, inputs, ... }: {
	packages = config.nvf
		|> lib.mapAttrs' (name: module: {
			name = "nvf-${name}";
			value = { pkgs }:
				lib.makeOverridable inputs.nvf.lib.neovimConfiguration {
					pkgs = pkgs;
					modules = [ module ];
				} |> (x: x.neovim // { nvfRaw = x; })
			;
		})
	;
}
