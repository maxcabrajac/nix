{ config, lib, util, inputs, ... }: let
	outputs = config.flake;
	inherit (lib.mapAttrs (_: lib.attrValues) outputs) nixosModules;

in {
	options = {
		dirs.hosts = lib.mkOption {
			type = lib.types.path;
		};
	};

	config.flake.nixosConfigurations =
		util.readDir config.dirs.hosts
		|> map ({ parts, path, ... }: {
			${parts.name} = import path;
		})
		|> lib.mergeAttrsList
		|> lib.mapAttrs (_: module: inputs.nixpkgs.lib.nixosSystem {
			specialArgs = {
				inherit util inputs;
			};
			modules = lib.flatten [
				nixosModules
				module
			];
		})
	;
}
