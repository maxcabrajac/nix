{ config, lib, inputs, ... }: {
	packages = config.nvf
		|> lib.mapAttrs' (name: module: {
			name = "nvf-${name}";
			value = { pkgs }:
				inputs.nvf.lib.neovimConfiguration {
					inherit pkgs;
					modules = [ module ];
				} |> (x: x.neovim)
			;
		})
	;
}
