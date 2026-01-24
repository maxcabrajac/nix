{ inputs, pkgs, ... }: {
	programs.anyrun = {
		enable = true;
		package = pkgs.anyrun;
		config = {
			ignoreExclusiveZones = true;
			y.fraction = 0.4;
			plugins = [
				"applications"
				"translate"
			];
			showResultsImmediately = true;
		};
	};
}
