{ lib, ... }: {
	hm.base = { config, pkgs, ... }: let
		cfg = config.programs.hyprlock;
	in {
		idleManagement.locker = lib.mkIf cfg.enable <| lib.mkDefault <| (
			pkgs.writeShellScript "lock" ''
				LOCK=''${XDG_RUNTIME_DIR:-/run/user/$(${lib.getExe' pkgs.coreutils "id"})}/hyprlock.lock
				[ -f $LOCK ] && echo "hyprlock already running!" && exit
				(
					touch $LOCK
					trap 'rm $LOCK' EXIT
					${lib.getExe cfg.package}
				) & disown
			''
			|> toString
		);
	};
}
