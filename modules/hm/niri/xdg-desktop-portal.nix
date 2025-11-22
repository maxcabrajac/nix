{ pkgs, lib, config, ... }: {
	xdg.portal.config.niri = lib.mkIf config.programs.niri.enable {
		"org.freedesktop.impl.portal.FileChooser" = let
			nautilusInstalled = config.home.packages |> lib.any (p: p == pkgs.nautilus);
		in
			lib.mkIf (!nautilusInstalled) (lib.mkDefault [ "gtk" ]);
	};
}
