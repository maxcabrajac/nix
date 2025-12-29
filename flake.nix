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

	outputs = inputs@{ flake-parts, self, nixpkgs, home-manager, systems, ... }: let
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
		pkgsFor = lib.genAttrs (import systems) (
			system:
			import nixpkgs {
				inherit system;
				config.allowUnfree = true;
			}
		);
		forEachSystem = f: lib.genAttrs (import systems) (system: f pkgsFor.${system});

		hosts =
			util.readDir ./hosts
			|> map ( { parts, path, ... }: {
				host = parts.name;
				module = import path;
			})
		;

		inherit (lib)
			attrValues
			filter
			flatten
			foldr
			listToAttrs
			map
			mapAttrs'
			mergeAttrs
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
			};

			systems = import inputs.systems;
			flake = rec {
				inherit util inputs;

				packageBundles =
					util.readDir ./pkgs
					|>	map ({ name, path, ... }: {
						inherit name;
						value = import path { inherit lib util inputs; };
					})
					|> listToAttrs
				;

				overlays = {
					self = (_: pkgs: packages.${pkgs.stdenv.hostPlatform.system} or {});
				};

				packages = forEachSystem (pkgs: let
					final = pkgs // self;
					callPackage = lib.callPackageWith final;
					self = packageBundles
						|> attrValues
						|> map (bundle: bundle.packages or {})
						|> foldr mergeAttrs {}
						|> lib.mapAttrs (_: drv: callPackage drv {})
					;
				in
					self // { inherit pkgs; }
				);

				nixosModules = lib.mergeAttrsList [
					{ inherit (home-manager.nixosModules) home-manager; }
					(packageBundles |> lib.mapAttrs (_: util.safeGetAttrFromPath ["nixosModule"] {}))
					{ hm-inject = {
							nixpkgs.overlays = outputs.overlays |> lib.attrValues;
							home-manager = {
								# Also forward args to home-manager modules
								extraSpecialArgs = { inherit util inputs; };
								sharedModules = config.flake.homeModules |> lib.attrValues;
								useGlobalPkgs = true;
							};
						};
					}
				];

				homeModules = lib.mergeAttrsList [
					(packageBundles |> lib.mapAttrs (_: util.safeGetAttrFromPath ["hmModule"] {}))
				];
			};
	});
}
