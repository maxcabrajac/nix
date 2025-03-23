{
	description = "Max's HM config";

	nixConfig = {
		extra-substituters = ["https://hyprland.cachix.org"];
		extra-trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
	};

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
		eww.url = "github:maxcabrajac/eww/include_dir";
		bttr_dispatchers = {
			url = "github:maxcabrajac/bttr_dispatchers";
			inputs.hyprland.follows = "hyprland";
		};
		nix-index = {
			url = "github:nix-community/nix-index-database";
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};

	outputs = inputs@{ self, nixpkgs, home-manager, ... }:
		let
			inherit (self) outputs;
			lib = nixpkgs.lib;
			system = builtins.currentSystem;
			maxLib = import ./lib {
				inherit pkgs;
				lib = lib // home-manager.lib;
			};
			packages_dir = import ./packages { inherit lib maxLib; };
			pkgs = import nixpkgs {
				inherit system;
				config.allowUnfree = true;
				inherit (outputs) overlays;
			};
			# helpers = maxLib.scriptDir { inherit pkgs; } ./scripts;
			forAllSystems = lib.genAttrs lib.systems.flakeExposed;
		in {
			overlays = [
				inputs.nixgl.overlay
				packages_dir.overlay
				(_:_: inputs.hyprland.packages.${system})
				(_:_: inputs.eww.packages.${system})
				(_:_: { inherit (home-manager.packages.${system}) home-manager; })
				(_:_: { hypr_plugs = [
					inputs.bttr_dispatchers.packages.${system}.bttr_dispatchers
				]; })
			];

			nixosConfiguration.main = lib.nixosSystem {

			};
			homeConfigurations = {
				main = home-manager.lib.homeManagerConfiguration {
					inherit pkgs;
					extraSpecialArgs = {
						inherit maxLib;
					};
					modules = [
						inputs.nix-index.hmModules.nix-index
						packages_dir.homeManagerModule
						./home.nix
						./progs
						./global
						./profiles
					];
				};
			};

			packages = forAllSystems (system: let
				getPacks = repo: repo.packages.${system};
			in {
				inherit (getPacks home-manager) home-manager;
			});
		};
}
