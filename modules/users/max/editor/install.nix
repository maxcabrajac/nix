{ lib, ... }: {
	user.max = { withSystem, ... }: let
		editor = withSystem.packages.nvf-max;
		bin = lib.getExe editor;
	in {
		home = {
			packages = [ editor ];
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
		};
	};
}
