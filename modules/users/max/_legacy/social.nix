{ pkgs, config, lib, inputs, ... }: lib.mkIf config.profiles.social {
	programs = {
		discord.enable = true;
	};

	home.packages = with pkgs; [
		# Telegram on pkgs crashes whenever another person open a video feed
		# See https://github.com/NixOS/nixpkgs/issues/563356
		inputs.telegram-nixpkgs.legacyPackages.${pkgs.stdenv.targetPlatform.system}.telegram-desktop
		element-desktop
	];
}
