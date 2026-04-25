{ config, lib, util, inputs, ... }: {
	options = {
		dirs.packages = lib.mkOption {
			type = lib.types.path;
		};
	};

	config = let
		packageBundles =
			util.readDir config.dirs.packages
			|>	map ({ parts, path, ... }: {
				inherit (parts) name;
				value = import path { inherit lib util inputs; };
			})
			|> lib.listToAttrs
		;
	in {
		flake = {
			inherit packageBundles;

			overlays.pkgDir = (pkgs: _: let
				callPackage = lib.callPackageWith pkgs;
				self = packageBundles
					|> lib.attrValues
					|> map (bundle: bundle.packages or {})
					|> lib.mergeAttrsList
					|> lib.mapAttrs (_: drv: callPackage drv {})
				;
			in
				self
			);

			nixosModules = packageBundles
				|> lib.mapAttrs (_: util.safeGetAttrFromPath ["nixosModule"] {});
			# TODO: rename hmModule
			homeModules = packageBundles
				|> lib.mapAttrs (_: util.safeGetAttrFromPath ["hmModule"] {});
		};

		perSystem = { pkgs, ... }: {
			packages = let
				isPack = lib.types.package.check;
			in
				lib.fix (final: config.flake.overlays.pkgDir (lib.recursiveUpdate pkgs final) pkgs)
				|> lib.mapAttrsToListRecursiveCond (_path: as: !isPack as)  (path: value: lib.optional (isPack value) {
					name = lib.concatStringsSep "-" path;
					inherit value;
				})
				|> lib.flatten
				|> lib.listToAttrs
			;
		};
	};
}
