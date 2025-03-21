{...}: {
	programs.fish.functions.autols = {
		body = "ls";
		onVariable = "PWD";
	};
}
