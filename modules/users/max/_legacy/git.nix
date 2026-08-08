{ pkgs, lib, ... }: {
	home.packages = [
		pkgs.pr-tracker
	];

	programs.git-manager.cloner = "${lib.getExe pkgs.jujutsu} git clone";

	home.shellAliases = {
		ggh = "gm github";
	};
}
