{ pkgs, lib, ... }: let
	inherit (pkgs.max-nvim) editor;
	bin = lib.getExe editor;
in {
	home = {
		sessionVariables = {
			EDITOR = bin;
			MANPAGER = "${bin} +Man!";
		};
		shellAbbrs = {
			e = "editor";
		};
		shellAliases = {
			editor = bin;
		};
		packages = [ editor ];
	};
}
