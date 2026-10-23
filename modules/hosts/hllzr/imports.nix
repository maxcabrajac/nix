{ config, ... }: {
	host.hllzr.imports = with config.os; [
		x86_64
		gui
	];
}

