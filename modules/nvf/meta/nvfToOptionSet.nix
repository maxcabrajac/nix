{ lib, ... }: let
	# INFO: This is a EXACT clone of https://github.com/NotAShelf/nvf/blob/ab3159aea7707333e689289a74545b26c1c9d37c/docs/default.nix#L37-L51
	scrubDerivations = namePrefix: pkgSet:
		builtins.mapAttrs (
			name: value: let
				wholeName = "${namePrefix}.${name}";
			in
				if builtins.isAttrs value
				then
					scrubDerivations wholeName value
					// lib.optionalAttrs (lib.isDerivation value) {
						inherit (value) drvPath;
						outPath = "\${${wholeName}}";
					}
				else value
		)
		pkgSet;
in {
	_module.args.nvfToOptionSet = nvf: nvf.nvfRaw.override ({ pkgs, ... }: {
		pkgs = scrubDerivations "pkgs" pkgs;
	}) |> (x: x.options);
}
