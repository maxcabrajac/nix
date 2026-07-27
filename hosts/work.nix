{ config, lib, pkgs, ... }: {
	humans."maximilian.cabrajac".hm = {
		from = "max";
		extraConfigs = {
			programs.fish.enable = true;

			home.shellAliases.ghi = "ggh inloco";
			home.sessionPath = [ "$HOME/.local/bin" ];
			home.stateVersion = "25.05"; # Did you read the comment?
		};
	};

	system.stateVersion = "25.05"; # Did you read the comment?
	nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
