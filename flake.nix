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
	};

	outputs = inputs@{ flake-parts, self, nixpkgs, home-manager, ... }: let
		lib = nixpkgs.lib // home-manager.lib;
		util = import ./util {
			inherit lib inputs;
		};

		# move to util
		allNixFiles = dir:
			dir
			|> util.readDirOpt { recursive = true; }
			|> filter (f: f.parts.extension == "nix")
			|> map (f: f.path)
		;


		inherit (self) outputs;

		inherit (lib)
			filter
			map
		;
	in
		flake-parts.lib.mkFlake { inherit inputs; } (top@{ config, ... }: {
			imports = lib.flatten [
				inputs.home-manager.flakeModules.home-manager
				(allNixFiles ./flake)
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

				nixosModules = {
					setOverlays = {
						nixpkgs.overlays = outputs.overlays |> lib.attrValues;
					};
				};
			};
	});
}
