{ pkgs, lib, config, ... }:
let
	cfg = config.programs.hypr;
	# Wrapper has to be installed alongside the main package, otherwise xdg-portal-hyprland's cachix is invalidated
	wrapper = with pkgs; writeShellApplication {
		name = "hypr";
		runtimeInputs = [ (config.lib.nixGL.wrap hyprland) ];
		text = "Hyprland";
	};
	# desktop_entry = with pkgs; makeDesktopItem {
	# 	name = "hyprland";
	# 	destination = "/usr/share/wayland-sessions/";
	# 	desktopName = "Hyprland";
	# 	comment = "NixGL wrapped Hyprland instance";
	# 	exec = (lib.getExe wrapper);
	# };
in {
	config = lib.mkIf cfg.enable {
		home.packages = [ wrapper ];
	};
}
