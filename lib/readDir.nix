{ lib, ... }: rec {
	readDir = dir:
		lib.attrsets.mapAttrsToList
			(file: _: lib.path.append dir file)
			(builtins.readDir dir);
	nonDefaultNix = dir: lib.lists.remove (dir + "/default.nix") (readDir dir);
}
