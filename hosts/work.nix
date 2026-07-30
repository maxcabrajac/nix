{ lib, ... }: {
	humans."maximilian.cabrajac".hm = {
		from = "max";
		extraConfigs = {
			variant = "work";
		};
	};

	system.stateVersion = "25.05"; # Did you read the comment?
	nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
