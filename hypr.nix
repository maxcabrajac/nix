{ lib, pkgs, ... }: let
	package = (pkgs.writeShellApplication {
		name = "hypr";
		runtimeInputs = with pkgs; [ nixgl.auto.nixGLDefault hyprland ];
		text = "nixGL Hyprland";
	});
in {
	inherit package;
}
