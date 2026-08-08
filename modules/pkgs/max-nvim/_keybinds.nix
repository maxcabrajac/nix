{ config, lib, ... } @ inputs: let
	noremap = mode: key: action: {
		inherit mode key action;
		noremap = true;
	};

	normalish = noremap [ "n" "x" "o" ];
in {
	vim.globals.mapleader = " ";
	vim.keymaps = lib.flatten [
		# basic colemak remapping

		# n -> j -> e -> k -> n
		(normalish "n" "j")
		# N -> J
		(normalish "j" "e")
		(normalish "J" "E")
		(normalish "e" "k")
		# E -> K
		(normalish "k" "n")
		(normalish "K" "N")

		# i -> l -> i
		(normalish "i" "l")
		# I -> L
		(normalish "l" "i")
		(normalish "L" "I")

		# long jumping
		(normalish "H" "0")
		(normalish "N" "<C-D>zz")
		(normalish "E" "<C-U>zz")
		(normalish "I" "$")

		# manual
		(normalish "M" "K")

		# Pannel Movement
		(noremap ["n"] "<leader>h" "<C-W><C-H>")
		(noremap ["n"] "<leader>n" "<C-W><C-J>")
		(noremap ["n"] "<leader>e" "<C-W><C-K>")
		(noremap ["n"] "<leader>i" "<C-W><C-L>")

		# Indent management
		(noremap ["n"] "<" "v<")
		(noremap ["n"] ">" "v>")
		(noremap ["x"] "<" "<gv")
		(noremap ["x"] ">" ">gv")

		# Normal funcs
		(noremap ["n"] ";" "A;<ESC>")
		(noremap ["n"] "C" "ciw")
		(noremap ["n"] "X" "daw")
		(noremap ["n"] "U" "<C-r>")
		(normalish "Q" "<CMD>q<CR>")
		(normalish "W" ''<CMD>silent w | echo "svd" @%<CR>'')

		# Copy and Paste
		(normalish "<C-y>" ''"+y'')
		(normalish "<C-p>" ''"+p'')
		(normalish "<C-d>" ''"+d'')

		# Arrow movements
		(normalish "<UP>" "gk")
		(normalish "<DOWN>" "gj")
		(noremap ["i"] "<UP>" "<C-o>gk")
		(noremap ["i"] "<DOWN>" "<C-o>gj")

		# Move lines
		(noremap ["n"] "<M-n>" "<CMD>m .+1<CR>")
		(noremap ["n"] "<M-e>" "<CMD>m .-2<CR>")
		(noremap ["n"] "<M-S-n>" "<CMD>t .<CR>")
		(noremap ["n"] "<M-S-e>" "<CMD>t .-1<CR>")

		(noremap ["x"] "<M-n>" ":m '>+1 | echo<CR>gv")
		(noremap ["x"] "<M-e>" ":m '<-2 | echo<CR>gv")
		(noremap ["x"] "<M-S-n>" ":t '>. | echo<CR>gv")
		(noremap ["x"] "<M-S-e>" ":t '<-1 | echo<CR>gv")

		# Exact mark jumping
		(normalish "'" "`")
	];
}
