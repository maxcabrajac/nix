{ config, lib, ... }: {
	nixpkgs.config.allowUnfree = true;
	nix.settings = {
		experimental-features = [ "nix-command" "flakes" "pipe-operators" ];
		trusted-users = [ "@wheel" ];
	};

	programs.nh = {
		enable = true;
		clean = {
			enable = true;
			# persistent = true;
			dates = "Sun *-*-* 12:00";
			extraArgs = "--keep 10 --keep-since 21d --optimise";
		};
	};
	# Manually set option on the timer
	systemd.timers.nh-clean.timerConfig.RandomizedDelaySec = "2h";
	# This should fail if the previous line ever becomes invalid
	assertions = [
		{
			assertion = config.systemd.services |> lib.attrByPath [ "nh-clean" "enable" ] false;
			message = "nh-clean service doesn't exist. Most likely it was renamed on nixpkgs.";
		}
	];
}
