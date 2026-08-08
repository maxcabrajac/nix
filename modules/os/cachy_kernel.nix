{ inputs, lib, ... }: {
	# TODO: make this platform agnostic
	os.cachy-kernel-x86 = {pkgs, ... }: {
		boot.kernelPackages = inputs.cachy-kernel.legacyPackages.x86_64-linux.linuxPackages-cachyos-latest-lto-x86_64-v3;
		specialisation = {
			base-kernel.configuration = {
				system.nixos.tags = [ "base-kernel" ];
				boot.kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
			};
		};
	};
}
