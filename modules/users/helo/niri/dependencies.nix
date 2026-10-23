{
	user.helo = { config, lib, ... }: lib.mkIf config.programs.niri.enable {
		global.keybinds = {
			M-Space.pkg = config.programs.walker.package;
		};
 		programs.walker.enable = true;
 		services.playerctld.enable = true;
		services.awww.enable = true;
	};
}
