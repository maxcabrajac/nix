{ inputs, ... }: {
	# Make non-steam launchers inherit protons
	hm.base = inputs.nix-gaming-edge.homeModules.steam-compat-tools;
	os.x86v3.programs.steam.extraCompatPackages = [
		inputs.nix-gaming-edge.packages.x86_64-linux.proton-cachyos-x86_64-v3
	];
}
