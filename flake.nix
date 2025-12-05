{
	description = "Nix Config";

	inputs = {
		nixpkgs.url = "nixpkgs/nixos-unstable";
		systems.url = "github:nix-systems/default-linux";
		home-manager = {
			url = "github:nix-community/home-manager";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		# Waiting on https://github.com/sodiboo/niri-flake/pull/1336 to be merged
		# niri-flake.url = "github:sodiboo/niri-flake";
		niri-flake = {
			url = "github:maxcabrajac/niri-flake";
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
	};

	outputs = inputs@{ self, nixpkgs, home-manager, systems, ... }: let
		inherit (self) outputs;
		lib = nixpkgs.lib // home-manager.lib;

		util = import ./util {
			inherit lib;
		};

		pkgsFor = lib.genAttrs (import systems) (
			system:
			import nixpkgs {
				inherit system;
				config.allowUnfree = true;
			}
		);
		forEachSystem = f: lib.genAttrs (import systems) (system: f pkgsFor.${system});

		allNixFiles = dir:
			dir
			|> util.readDirOpt { recursive = true; }
			|> filter (f: f.parts.extension == "nix")
			|> map (f: f.path)
		;

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
	in rec {
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
			xdp = (_: pkgs: { xdg-desktop-portal = pkgs.xdg-desktop-portal-git or pkgs.xdg-desktop-portal; } );
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

		nixosModules = flatten [
			home-manager.nixosModules.home-manager
			(packageBundles |> attrValues |> map (util.safeGetAttrFromPath ["nixosModule"] {}))
			(allNixFiles ./modules/nixos)
		];

		hmModules = flatten [
			(packageBundles |> attrValues |> map (util.safeGetAttrFromPath ["hmModule"] {}))
			(allNixFiles ./modules/hm)
		];

		nixosConfigurations =
			hosts
			|> map (host: {
				name = host.host;
				value = lib.nixosSystem rec {
					specialArgs = {
						inherit util inputs;
					};
					modules = flatten [
						{
							nixpkgs.overlays = outputs.overlays |> lib.attrValues;
							home-manager = {
								# Also forward args to home-manager modules
								extraSpecialArgs = specialArgs;
								sharedModules = hmModules;
								useGlobalPkgs = true;
							};
						}
						nixosModules
						host.module
					];
				};
			})
			|> listToAttrs
		;

		homeConfigurations =
			hosts
			|> map ({ host, ... }: let
				userConfigs = nixosConfigurations.${host}.config.home-manager.users;
			in
				userConfigs |> mapAttrs' (username: config: {
					name = "${username}@${host}";
					value = { inherit config; };
				})
			)
			|> foldr mergeAttrs {}
		;
	};
}
