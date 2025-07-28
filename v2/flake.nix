{
	description = "Nix Config";

	inputs = {
		nixpkgs.url = "nixpkgs/nixos-unstable";
		systems.url = "github:nix-systems/default-linux";
		home-manager = {
			url = "github:nix-community/home-manager";
			inputs.nixpkgs.follows = "nixpkgs";
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

		hosts =
			util.readDir ./hosts
			|> map (file: {
				host = (util.fileParts file).name;
				module = import file;
			})
		;

		inherit (lib)
			attrValues
			filter
			flatten
			fold
			listToAttrs
			map
			mapAttrs'
			mergeAttrs
		;

		commonModules = flatten [
			{
				nixpkgs.overlays = outputs.overlays |> lib.attrValues;
				home-manager = {
					useGlobalPkgs = true;
				};
			}
			(util.readDir ./common)
			self.nixosModules
			{ home-manager.sharedModules = self.hmModules; }
		];
	in rec {
		inherit util;

		packageBundles =
			util.readDir' ./pkgs
			|>	map ({ name, file, ... }: {
				inherit name;
				value = import file { inherit lib util; };
			})
			|> listToAttrs
		;

		overlays = {
			self = (final: pkgs:
				packageBundles
				|> attrValues
				|>	map (bundle: bundle.packages { pkgs = final; })
				|> fold mergeAttrs {}
			);
		};

		packages = forEachSystem (pkgs:
			pkgs
			|> lib.flip outputs.overlays.self
			|> lib.fix
		);

		nixosModules = flatten [
			home-manager.nixosModules.home-manager
			(packageBundles |> attrValues |> map (util.safeGetAttrFromPath ["nixosModule"] {}))
			(util.readDir ./modules/nixos)
		];

		hmModules = flatten [
			(packageBundles |> attrValues |> map (util.safeGetAttrFromPath ["hmModule"] {}))
			(util.readDir ./modules/hm)
		];

		nixosConfigurations =
			hosts
			|> map (host: {
				name = host.host;
				value = lib.nixosSystem rec {
					specialArgs = {
						inherit util;
					};
					modules = flatten [
						{
							nixpkgs.overlays = outputs.overlays |> lib.attrValues;
							home-manager = {
								# Also forward args to home-manager modules
								extraSpecialArgs = specialArgs;
								sharedModules = hmModules;
								useGlobalPkgs = true;
								useUserPackages = true;
							};
						}
						(util.readDir ./common)
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
					value = config.home;
				})
			)
			|> fold mergeAttrs {}
		;
	};
}
