{ lib, util, ... } @ input: let
in {
	packages = { pkgs, ... }: with pkgs; {
		notify-send = libnotify;
	};
}

