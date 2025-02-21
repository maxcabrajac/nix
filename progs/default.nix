{ lib, maxLib, ...}: {
	imports = (maxLib.nonDefaultNix ./.);
}
