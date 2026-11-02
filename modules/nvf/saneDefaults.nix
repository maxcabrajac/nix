{
	nvf.base = { pkgs, ... }: {
		vim = {
			debugMode = {
				enable = false;
				level = 16;
				logFile = "/tmp/nvim.log";
			};

			lsp = {
				enable = true;
				lspkind.enable = true;
				lspSignature.enable = true;
				otter-nvim.enable = true;
			};

			languages = {
				enableFormat = true;
				enableTreesitter = true;
				enableExtraDiagnostics = true;
			};

			visuals.fidget-nvim.enable = true;
			statusline.lualine.enable = true;

			autocomplete.nvim-cmp.enable = true;

			treesitter = {
				context.enable = true;
				grammars = pkgs.vimPlugins.nvim-treesitter.allGrammars;
			};

			binds.whichKey.enable = true;

			notes.todo-comments.enable = true;

			ui = {
				borders.enable = true;
				colorizer.enable = true;
				illuminate.enable = true;
			};

			comments.comment-nvim = {
				enable = true;
				mappings = {
					toggleCurrentLine = "<M-/>";
					toggleSelectedLine = "<M-/>";
				};
			};

			options = {
				mouse = "a";
				hlsearch = false;
				scrolloff = 5;
				copyindent = true;

				ignorecase = true;
				smartcase = true;
				inccommand = "nosplit";
			};

		};
	};
}
