{ lib, pkgs, ... }: {
	package = pkgs.writeShellApplication {
		name = "hypr";
		runtimeInputs = with pkgs; [ nixgl.auto.nixGLDefault hyprland ];
		text = "nixGL Hyprland";
	};

	config = {

	};
}
