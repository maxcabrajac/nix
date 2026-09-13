{ config, ... }: {
	host.nixos.imports = with config.os; [
		x86_64
		gaming
		gui
	];
}

