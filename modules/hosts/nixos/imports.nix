{ config, ... }: {
	host.nixos.imports = with config.os; [
		cachy-kernel-x86
		gaming
		gui
	];
}

