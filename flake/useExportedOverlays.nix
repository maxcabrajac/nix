{ config, lib, ... }: {
	flake.nixosModules.useExportedOverlays = {
		nixpkgs.overlays = config.flake.overlays |> lib.attrValues;
	};
}
