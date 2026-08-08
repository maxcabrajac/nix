{ config, lib, ... }: {
	os.base.nixpkgs.overlays =
		config.flake.overlays
		|> lib.attrValues
	;
}
