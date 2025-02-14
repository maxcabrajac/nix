{ lib, ...}: {
	imports = lib.lists.remove ./default.nix (lib.attrsets.mapAttrsToList (file: _: lib.path.append ./. file) (builtins.readDir ./.));
}
