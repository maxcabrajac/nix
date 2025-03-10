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

	outputs = inp@{ nixpkgs, home-manager, ... }:
		let
			lib = nixpkgs.lib;
			system = builtins.currentSystem;
			pkgs = import nixpkgs {
				inherit system;
				config.allowUnfree = true;
				overlays = [
					inp.nixgl.overlay
					(_:_: inp.hyprland.packages.${system})
					(_:_: inp.eww.packages.${system})
					(_:_: { inherit (home-manager.packages.${system}) home-manager; })
					(_:_: { hypr_plugs = [
						inp.bttr_dispatchers.packages.${system}.bttr_dispatchers
					]; })
				];
			};
			maxLib = import ./lib {
				inherit pkgs;
				lib = lib // home-manager.lib;
			};
			helpers = maxLib.scriptDir { inherit pkgs; } ./scripts;
		in {
			homeConfigurations = {
				main = home-manager.lib.homeManagerConfiguration {
					inherit pkgs;
					extraSpecialArgs = {
						inherit maxLib helpers;
					};
					modules = [
						inp.nix-index.hmModules.nix-index
						./home.nix
						./progs
					];
				};
			};

			inherit home-manager;
			inherit (home-manager) packages;
		};
}
