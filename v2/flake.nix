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
					overlays = outputs.overlays;
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
				flatten
				fold
				listToAttrs
				map
				mapAttrs'
				mergeAttrs
			;

			commonModules = flatten [
				{ nixpkgs.overlays = outputs.overlays; }
				(util.readDir ./common)
				(util.readDir ./global)
				(util.readDir ./profiles)
			];
		in rec {
			packages = forEachSystem (pkgs:
				lib.fix (self:
					util.readDir ./pkgs
					|>	map (file: import file { pkgs = pkgs // self; inherit lib util; })
					|> fold mergeAttrs {}
				)
			);

			overlays = [
				(final: _: outputs.packages.${final.system})
			];

			nixosConfigurations =
				hosts
				|> map (host: {
					name = host.host;
					value = lib.nixosSystem {
						modules = commonModules ++ [
							host.module
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
