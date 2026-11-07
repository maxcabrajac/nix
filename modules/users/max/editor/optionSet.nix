{ nvfToOptionSet, ... }: {
	user.max = { withSystem, ... }: {
		optionSets.nvf = nvfToOptionSet withSystem.packages.nvf-max;
	};
}
