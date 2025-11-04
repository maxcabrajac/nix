{ config, lib, pkgs, ... }: {
	boot = {
		loader = {
			systemd-boot.enable = true;
			efi.canTouchEfiVariables = true;
		};

		# clean /tmp
		tmp.cleanOnBoot = true;
	};

	# Use latest kernel.
	boot.kernelPackages = pkgs.linuxPackages_latest;

	# Enable OpenGL
	hardware.graphics = {
		enable = true;
	};

	# Load nvidia driver for Xorg and Wayland
	services.xserver.videoDrivers = ["nvidia"];

	hardware.nvidia = {
		open = false;
		# Enable the Nvidia settings menu,
		# accessible via `nvidia-settings`.
		nvidiaSettings = true;
	};

	console = {
		font = "Lat2-Terminus16";
		keyMap = "colemak";
	};

	services.displayManager.sddm = {
		enable = true;
		wayland.enable = true;
	};

	services.pipewire = {
		enable = true;
		pulse.enable = true;
	};

	services.automatic-timezoned.enable = true;

	# Define a user account. Don't forget to set a password with ‘passwd’.
	humans.max = {
		extraGroups = [ "wheel" "docker" ]; # Enable ‘sudo’ for the user.
	};
	home-manager.users.max = {
		profiles = {
			gui = true;
			games = true;
		};
		programs.fish.enable = true;
		home.stateVersion = "25.05"; # Did you read the comment?
	};

	# List packages installed in system profile.
	# You can use https://search.nixos.org/ to find more packages (and options).
	environment.systemPackages = with pkgs; [
		gnumake
		wget
		kitty
		git
		jujutsu
		gcc
		discord
		telegram-desktop
		waybar
		neovim
		nh
	];

	system.stateVersion = "25.05"; # Did you read the comment?

	programs.steam = {
		enable = true;
		remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
		dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
		localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
	};

	virtualisation.docker = {
		enable = true;
		storageDriver = "btrfs";
	};

	# HARDWARE

	hardware.enableRedistributableFirmware = true;

	boot = {
		initrd = {
			availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
			kernelModules = [ ];
		};
		kernelModules = [ "kvm-amd" ];
		extraModulePackages = [ ];
	};

	fileSystems = {
		"/" = {
			device = "/dev/disk/by-uuid/3ad17340-7122-4887-983d-09ab4d7cccdd";
			fsType = "btrfs";
		};

		"/boot" = {
			device = "/dev/disk/by-uuid/C65C-15B2";
			fsType = "vfat";
			options = [ "fmask=0022" "dmask=0022" ];
		};
	};

	swapDevices = [ ];

	nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
	hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
