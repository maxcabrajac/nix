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

	outputs = inputs@{ self, nixpkgs, home-manager, systems, ... }:
		let
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
					overlays = [];
				}
			);
			forEachSystem = f: lib.genAttrs (import systems) (system: f pkgsFor.${system});

			hosts =
				util.readDir ./hosts
				|> map (file: import file // {
					host = (util.fileParts file).name;
				});

			inherit (lib)
				filter
				listToAttrs
				map
				mapAttrs'
				mergeAttrs
				fold
			;
		in rec {
			inherit hosts;

			nixosConfigurations =
				hosts
				|> map ({ host, module, ... }: {
					name = host;
					value = lib.nixosSystem {
						modules = [
							module
							home-manager.nixosModules.home-manager
						];
					};
				})
				|> listToAttrs;

			homeConfigurations =
				hosts
				|> filter ({ isNixOs, ... }: !isNixOs)
				|> map ({ host, ... }: let
					userConfigs = nixosConfigurations.${host}.config.home-manager.users;
				in
					userConfigs |> mapAttrs' (username: config: {
						name = "${username}@${host}";
						value = config.home;
					})
				)
				|> fold mergeAttrs {};
		};
}
