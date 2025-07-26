{ lib, config, util, ... }: {
	imports = (util.readDir ./nixos);
	home-manager.sharedModules = (util.readDir ./hm);
}
