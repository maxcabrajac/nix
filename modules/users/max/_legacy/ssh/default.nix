{ lib, config, ... }: {
	options.sshKey = lib.mkEnableOption "sshKeys" // {
		default = true;
	};
	config = {
		secretFiles.sshPriv = {
			enable = config.sshKey;
			src = ./id_ed25519;
			dest = "${config.home.homeDirectory}/.ssh/id_ed25519";
		};
		home.file.sshPub = {
			enable = config.sshKey;
			source = ./id_ed25519.pub;
			target = ".ssh/id_ed25519.pub";
		};
	};
}
