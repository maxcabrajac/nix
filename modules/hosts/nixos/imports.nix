{ config, ... }: {
	host.nixos.imports = with config.os; [
		x86v3
		gaming
		gui
	];
}

