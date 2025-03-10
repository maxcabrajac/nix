{ pkgs, lib, helpers, ... }: {
	imports = [
		../profiles/hyprland.nix
		../profiles/terminal.nix
		../profiles/fonts.nix
	];

	home = {
		packages = lib.flatten [
			pkgs.nixd
			helpers.all
		];
	};

	# nix-based pam.so doesn't seem to work on arch
	programs.hyprlock.package = pkgs.emptyDirectory;

	nixGL = {
		packages = pkgs.nixgl;
	};
}
