{ inputs, lib, ...  }: {
	packages.max-nvim = { pkgs, ... }: let
		modulesPerPackage = rec {
			base = [
				{ _module.args = { flakeInputs = inputs; };  }
				./keybinds.nix
			];

			editor = base ++ [
				./config.nix
			];
		};

		mkNvim = modules:	(inputs.nvf.lib.neovimConfiguration { inherit pkgs modules; }).neovim;
	in
		modulesPerPackage
		|> lib.mapAttrs (_: mkNvim)
		|> lib.mapAttrs (name: p: {
			"${name}" = p;
			"${name}-renamed" = pkgs.linkFarm "${name}-renamed" [
				{ name = "bin/${name}"; path = lib.getExe p; }
			];
		})
		|> lib.attrValues
		|> lib.foldr (a: b: a // b) {}
	;
}

