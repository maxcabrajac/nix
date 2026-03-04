{ inputs, pkgs, lib, ... }: let
	editor = inputs.max-nvim.packages.${pkgs.stdenv.hostPlatform.system}.editor;
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
