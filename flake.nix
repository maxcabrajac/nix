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

		mabar = {
			url = "github:maxcabrajac/mabar";
			inputs.nixpkgs.follows = "nixpkgs";
			inputs.systems.follows = "systems";
			inputs.flake-parts.follows = "flake-parts";
		};

		xdp-git = {
			url = "github:flatpak/xdg-desktop-portal/1.21.1";
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
			url = "github:abenz1267/walker/v2.15.2";
			inputs.elephant.follows = "elephant";
			inputs.nixpkgs.follows = "nixpkgs";
			inputs.systems.follows = "systems";
		};

		cachy-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

		nvf = {
			url = "github:NotAShelf/nvf";
			inputs = {
				flake-parts.follows = "flake-parts";
				systems.follows = "systems";
			};
		};

		# max-nvim
		nvim-ayu = { url = "github:Luxed/ayu-vim"; flake = false; };
	};

	nixConfig = {
		extra-experimental-features = [
			"pipe-operators"
		];

		extra-substituters = [
			"https://walker-git.cachix.org"
			"https://attic.xuyh0120.win/lantian" # cachy-kernel
		];

		extra-trusted-public-keys = [
			"walker-git.cachix.org-1:vmC0ocfPWh0S/vRAQGtChuiZBTAe4wiKDeyyXM0/7pM="
			"lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc=" # cachy-kernel
		];
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
