{ inputs, ... }: {
	# TODO: make this platform agnostic
	os.cachy-kernel-x86 = {
		boot.kernelPackages = inputs.cachy-kernel.legacyPackages.x86_64-linux.linuxPackages-cachyos-latest-lto-x86_64-v3;
	};
}
