{ lib, config, ... }: let
	inherit (lib.generators) mkLuaInline;

	cfg = config.vim.autocomplete.nvim-cmp;
in {
	options.vim.autocomplete.nvim-cmp = {
		completeopt = lib.mkOption {
			type = with lib.types; attrsOf bool;
		};
	};

	config.vim.autocomplete.nvim-cmp = {
		completeopt = {
			menu = lib.mkDefault true;
			menuone = lib.mkDefault true;
			noinsert = lib.mkDefault true;
		};

		setupOpts.completion.completeopt = cfg.completeopt
			|> lib.filterAttrs (_: x: x)
			|> lib.attrNames
			|> lib.concatStringsSep ","
		;
	};
}
