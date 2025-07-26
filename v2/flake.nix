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
				}
			);
			forEachSystem = f: lib.genAttrs (import systems) (system: f pkgsFor.${system});

			hosts =
				util.readDir ./hosts
				|> map (file: import file // {
					host = (util.fileParts file).name;
				})
			;

			inherit (lib)
				filter
				flatten
				fold
				listToAttrs
				map
				mapAttrs'
				mergeAttrs
			;

			commonModules = flatten [
				home-manager.nixosModules.home-manager
				{
					nixpkgs.overlays = outputs.overlays |> lib.attrValues;
					home-manager = {
						useGlobalPkgs = true;
						useUserPackages = true;
					};
				}
				(util.readDir ./common)
				(util.readDir ./global)
				(util.readDir ./profiles)
			];
		in rec {
			packages = forEachSystem (pkgs:
				pkgs
				|> lib.flip outputs.overlays.self
				|> lib.fix
			);

			overlays = {
				self = (final: pkgs:
					util.readDir ./pkgs
					|>	map (file: import file { pkgs = final; inherit lib util; })
					|> fold mergeAttrs {}
				);
			};

			nixosConfigurations =
				hosts
				|> map (host: {
					name = host.host;
					value = lib.nixosSystem {
						modules = commonModules ++ [
							host.module
						];
					};
				})
				|> listToAttrs
			;

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
				|> fold mergeAttrs {}
			;
		};
}
