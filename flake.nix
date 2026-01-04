{
	description = "Nix Config";

	inputs = {
		nixpkgs.url = "nixpkgs/nixos-unstable";
		flake-parts.url = "github:hercules-ci/flake-parts";
		systems.url = "github:nix-systems/default-linux";

		home-manager = {
			url = "github:nix-community/home-manager";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		niri-flake = {
			url = "github:sodiboo/niri-flake";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		max-nvim = {
			url = "github:maxcabrajac/nvf-configs";
			# WARN: nixpkgs upstream broke tree-sitter
			# Follow github.com/NotAShelf/nvf/issues/1312
			# inputs.nixpkgs.follows = "nixpkgs";
		};

		mabar = {
			url = "github:maxcabrajac/mabar";
			inputs.nixpkgs.follows = "nixpkgs";
			inputs.systems.follows = "systems";
		};

		xdp-git = {
			url = "github:maxcabrajac/xdg-desktop-portal/pr";
			flake = false;
		};

		# this is HUGE
		wallpkgs.url = "github:NotAShelf/wallpkgs";

		elephant = {
			url = "github:maxcabrajac/elephant/websearch";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		walker = {
			url = "github:abenz1267/walker";
			inputs.elephant.follows = "elephant";
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};

	outputs = inputs@{ flake-parts, self, nixpkgs, home-manager, ... }: let
		lib = nixpkgs.lib // home-manager.lib;
		util = import ./util {
			inherit lib inputs;
		};
	in
		flake-parts.lib.mkFlake { inherit inputs; } (top@{ config, ... }: {
			imports = lib.flatten [
				inputs.home-manager.flakeModules.home-manager
				(util.allNixFiles ./flake)
			];

			_module.args = {
				inherit util;
			};

			dirs = {
				hosts = ./hosts;
				modules = ./modules;
				packages = ./pkgs;
			};

			systems = import inputs.systems;
			flake = {
				inherit util inputs;
			};
	});
}
