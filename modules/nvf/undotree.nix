{
	nvf.base.vim = {
		lazy.plugins = {
			undotree = {
				package = "undotree";
				keys = [
					{
						desc = "Open UndoTree";
						mode = "";
						key = "<leader>u";
						action = "<cmd>UndotreeToggle<CR>";
					}
				];
				cmd = [ "UndotreeToggle" ];
			};
		};
		options = {
			undofile = true;
			backup = false;
			writebackup = false;
		};
	};
}
