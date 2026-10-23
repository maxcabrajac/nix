{
	host.hllzr = {
		boot.loader = {
			systemd-boot.enable = true;
			efi.canTouchEfiVariables = true;
		};

		services.displayManager.ly.enable = true;
		programs.steam.enable = true;

		networking = {
			hostName = "hllzr";
			networkmanager.enable = true;
		};

		monitors = {
			"eDP-1" = {
				x = 0;
				y = 0;

				w = 1920;
				h = 1080;
				refresh = 60.002;
			};

			"DP-1" = {
				x = 1920;
				y = 0;

				w = 1920;
				h = 1080;
				refresh = 60.0;

				main = true;
			};
		};

		system.stateVersion = "25.05"; # Did you read the comment?

		# HARDWARE
		hardware.facter.enable = true;
		hardware.facter.reportPath = ./facter.json;

		fileSystems = {
			"/" = {
				device = "/dev/disk/by-uuid/12661a73-49ed-4352-8458-5006b782c525";
				fsType = "btrfs";
			};

			"/home" = {
				device = "/dev/disk/by-uuid/12661a73-49ed-4352-8458-5006b782c525";
				fsType = "btrfs";
				options = [ "subvol=home" ];
			};

			"/nix" = {
				device = "/dev/disk/by-uuid/12661a73-49ed-4352-8458-5006b782c525";
				fsType = "btrfs";
				options = [ "subvol=nix" ];
			};

			"/boot" = {
				device = "/dev/disk/by-uuid/C944-9DA8";
				fsType = "vfat";
				options = [ "fmask=0077" "dmask=0077" ];
			};
		};
	};
}
