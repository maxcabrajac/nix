# TODO: Remove all of this
{ lib, ... }: {
	hm.base.options.profiles = lib.genAttrs [
		"gui"
	] (name: lib.mkEnableOption name);
}
