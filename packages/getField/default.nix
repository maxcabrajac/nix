{ lib, maxLib, ...}: let
	inherit (lib.fixedPoints) fix;
	inherit (maxLib) mapDir;
in {
	packages = pkgs: fix (self:
		mapDir (pkgs.makeScript { inherit self pkgs; }) ./scripts
	);
}
