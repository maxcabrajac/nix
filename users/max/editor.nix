{ inputs, pkgs, lib, ... }: let
	editor = inputs.max-nvim.packages.${pkgs.system}.editor;
in {
	home = {
		sessionVariables = {
			EDITOR = lib.getExe editor;
		};
		shellAbbrs = {
			e = "editor";
		};
		shellAliases = {
			editor = lib.getExe editor;
		};
		packages = [ editor ];
	};
}
