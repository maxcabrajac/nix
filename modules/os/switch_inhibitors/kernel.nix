{
	os.base = { config, ... }: {
		system.switch.inhibitors.kernelVersion = config.boot.kernelPackages.kernel.version;
	};
}
