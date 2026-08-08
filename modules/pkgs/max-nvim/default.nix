{ inputs, lib, ...  }: {
	packages.editor = { pkgs, ... }: let
		modulesPerPackage = rec {
			base = [
				{ _module.args = { flakeInputs = inputs; };  }
				(inputs.import-tree ./_modules)
				./_keybinds.nix
			];

			editor = base ++ [
				./_config.nix
			];
		};

		mkNvim = modules:	(inputs.nvf.lib.neovimConfiguration { inherit pkgs modules; }).neovim;
	in
		# TODO: Add back other packages (See v2 tag for reference)
		mkNvim modulesPerPackage.editor
	;
}

