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
			inputs.nixpkgs.follows = "nixpkgs";
			inputs.flake-parts.follows = "flake-parts";
			inputs.systems.follows = "systems";
		};

		mabar = {
			url = "github:maxcabrajac/mabar";
			inputs.nixpkgs.follows = "nixpkgs";
			inputs.systems.follows = "systems";
			inputs.flake-parts.follows = "flake-parts";
		};

		xdp-git = {
			url = "github:flatpak/xdg-desktop-portal";
			flake = false;
		};

		# this is HUGE
		wallpkgs.url = "github:NotAShelf/wallpkgs";

		elephant = {
			url = "github:maxcabrajac/elephant/websearch";
			inputs.nixpkgs.follows = "nixpkgs";
			inputs.systems.follows = "systems";
		};
		walker = {
			url = "github:abenz1267/walker";
			inputs.elephant.follows = "elephant";
			inputs.nixpkgs.follows = "nixpkgs";
			inputs.systems.follows = "systems";
		};
	};

	nixConfig = {
		extra-experimental-features = [ "pipe-operators" ];
	};

	outputs = inputs@{ flake-parts, nixpkgs, home-manager, ... }: let
		lib = nixpkgs.lib // home-manager.lib;
		util = import ./util {
			inherit lib inputs;
		};
	in
		flake-parts.lib.mkFlake { inherit inputs; } {
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
	};
}
