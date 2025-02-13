{
	description = "Max's HM config";

	inputs = {
		nixpkgs.url = "nixpkgs/nixos-unstable";

		home-manager = {
			url = "github:nix-community/home-manager";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		hyprland.url = "github:hyprwm/Hyprland";
		# nixgl.url = "github:nix-community/nixGL";
		# This is a in-progress PR
		nixgl.url = "github:bb010g/nixGL";
	};

	nixConfig = {
		extra-substituters = ["https://hyprland.cachix.org"];
		extra-trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
	};

	outputs = { nixpkgs, home-manager, hyprland, nixgl, ... }:
		let
			lib = nixpkgs.lib;
			system = "x86_64-linux";
			pkgs = builtins.foldl' lib.recursiveUpdate {} [
				(
					import nixpkgs {
						inherit system;
						config.allowUnfree = true;
						overlays = [ nixgl.overlay ];
					}
				)
				hyprland.packages.${system}
			];
		in {
			homeConfigurations = {
				main = home-manager.lib.homeManagerConfiguration {
					inherit pkgs;
					modules = [
						./home.nix
					];
				};
			};

			inherit home-manager;
			inherit (home-manager) packages;
		};
}
