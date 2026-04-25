{ lib, config, ... }: let
	inherit (lib.generators) mkLuaInline;

	cfg = config.vim.autocomplete.nvim-cmp;
in {
	options.vim.autocomplete.nvim-cmp = {
		preselect = lib.mkEnableOption "preselection" // { default = true; };
	};

	config.vim.autocomplete.nvim-cmp = lib.mkIf (!cfg.preselect) {
		completeopt.noselect = true;
		setupOpts.mapping = {
			"${cfg.mappings.confirm}" = lib.mkForce <| mkLuaInline "cmp.mapping.confirm()";
		};
	};
}
