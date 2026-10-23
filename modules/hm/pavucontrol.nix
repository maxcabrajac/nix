{ lib, ... }: {
	hm.base = { osConfig, pkgs, ... }: {
		home.packages = lib.mkIf (osConfig.services.pipewire.enable or false) [
			pkgs.pavucontrol
		];
	};
}
