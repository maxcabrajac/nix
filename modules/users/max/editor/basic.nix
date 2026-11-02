{ lib, inputs, ... }: {
	nvf.max = {
		vim = {
			lsp = {
				trouble.enable = true;
				mappings = {
					goToDefinition = "M";
					hover = "mm";
					renameSymbol = "<leader>c";
				};
			};

			languages = {
				nix = {
					enable = true;
					extraDiagnostics.types = [ "deadnix" ];
					lsp.servers = [ "nixd" ];
				};
				markdown.enable = true;
				bash.enable = true;
				python = {
					enable = true;
					lsp.servers = ["pyrefly"];
				};
				clang.enable = true;
				go.enable = true;
				rust.enable = true;
			};

			statusline.lualine.setupOpts.options.theme = "ayu_dark";

			lazy.plugins = {
				ayu = {
					package = inputs.nvim-ayu // { name = "ayu"; };
					lazy = false;
					after = ''vim.cmd("colorscheme ayu")'';
				};
				leap-nvim = {
					package = "leap-nvim";
					keys = [
						{
							desc = "Jump with vim leap";
							mode = [ "n" "x" "o" ];
							key = "s";
							action = "<Plug>(leap-anywhere)";
						}
					];
				};
			};

			autocomplete = {
				nvim-cmp = {
					mappings = {
						next = "<C-n>";
						previous = "<C-e>";
						scrollDocsDown = "<M-n>";
						scrollDocsUp = "<M-e>";
						close = "<C-i>";
					};
					preselect = false;
				};
			};

			augroups = [
				{ name = "rnuToggle"; }
			];

			autocmds = lib.flatten [
				{
					desc = "Highlight on yank";
					event = [ "TextYankPost" ];
					callback = lib.generators.mkLuaInline /* lua */''
						function ()
							vim.hl.on_yank({ timeout = 300 })
						end
					'';
				}
				{
					desc = "Trim whitespace";
					event = [ "BufWritePre" ];
					callback = lib.generators.mkLuaInline /* lua */''
						function ()
							local save = vim.fn.winsaveview()
							vim.api.nvim_command([[keeppatterns silent %s/\\\@<!\s\+$//e]])
							vim.fn.winrestview(save)
						end
					'';
				}
				(let
					base = state: {
						group = "rnuToggle";
						callback = lib.generators.mkLuaInline /* lua */''
							function ()
								if vim.opt.number:get() then
									vim.opt.relativenumber = ${lib.boolToString state}
								end
							end
						'';
					};
					variants = {
						enable = {
							event = [ "BufEnter" "FocusGained" "InsertLeave" ];
							state = true;
						};
						disable = {
							event = [ "BufLeave" "FocusLost" "InsertEnter" ];
							state = false;
						};
					};
				in
					variants
					|> lib.mapAttrs (desc: { event, state }: { inherit desc event; } // (base state))
					|> lib.attrValues
				)
			];

			options = {
				expandtab = false;
				preserveindent = true;
				softtabstop = 0;
				shiftwidth = 3;
				tabstop = 3;

				list = true;
				listchars = "tab:  ,trail:~,eol: ,extends: ";
				showbreak = ">==>";
				linebreak = true;
			};

			# INFO: I have no clue why this is here =/
			globals.no_man_maps = 1;
		};
	};
}
