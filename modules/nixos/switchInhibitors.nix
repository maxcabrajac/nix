{ config, ... }: {
	system.switch.inhibitors.kernel_version = config.boot.kernelPackages.kernel.version;
}
