{ config, lib, pkgs, ... }: {
	# Use the systemd-boot EFI boot loader.
	boot.loader.systemd-boot.enable = true;
	boot.loader.efi.canTouchEfiVariables = true;

	# clean /tmp
	boot.tmp.cleanOnBoot = true;

	# Use latest kernel.
	boot.kernelPackages = pkgs.linuxPackages_latest;

	hardware.graphics.enable = true;
	hardware.nvidia.open = false;

	home-manager.users.max = {
		programs.fish.enable = true;
		home.stateVersion = "25.05"; # Did you read the comment?
	};

	console = {
		font = "Lat2-Terminus16";
		keyMap = "colemak";
	};

	# gnome
	services.xserver = {
		enable = true;
		videoDrivers = [ "nvidia" ];
		displayManager.gdm.enable = true;
	};

	# Enable the X11 windowing system.
	# services.xserver.enable = true;

	# Configure keymap in X11
	services.xserver.xkb.layout = "us";
	services.xserver.xkb.variant = "colemak";

	# Enable CUPS to print documents.
	# services.printing.enable = true;

	# Enable sound.
	# services.pulseaudio.enable = true;
	# OR
	services.pipewire = {
		enable = true;
		pulse.enable = true;
	};

	services.automatic-timezoned.enable = true;

	# Enable touchpad support (enabled default in most desktopManager).
	# services.libinput.enable = true;

	# Define a user account. Don't forget to set a password with ‘passwd’.
	users.humans.max = {
		extraGroups = [ "wheel" "docker" ]; # Enable ‘sudo’ for the user.
	};
	home-manager.users.max = {
		profiles = {
			gui = true;
			games = true;
		};
	};

	# List packages installed in system profile.
	# You can use https://search.nixos.org/ to find more packages (and options).
	environment.systemPackages = with pkgs; [
		gnumake
		vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
		wget
		kitty
		fuzzel
		git
		jujutsu
		gcc
		discord
		telegram-desktop
		xwayland-satellite
		waybar
		neovim
		nh
	];

	programs.niri.enable = true;

	# Some programs need SUID wrappers, can be configured further or are
	# started in user sessions.
	# programs.mtr.enable = true;
	# programs.gnupg.agent = {
	#	 enable = true;
	#	 enableSSHSupport = true;
	# };

	# List services that you want to enable:

	# Enable the OpenSSH daemon.
	# services.openssh.enable = true;

	# Open ports in the firewall.
	# networking.firewall.allowedTCPPorts = [ ... ];
	# networking.firewall.allowedUDPPorts = [ ... ];
	# Or disable the firewall altogether.
	# networking.firewall.enable = false;

	# Copy the NixOS configuration file and link it from the resulting system
	# (/run/current-system/configuration.nix). This is useful in case you
	# accidentally delete configuration.nix.
	# system.copySystemConfiguration = true;

	# This option defines the first version of NixOS you have installed on this particular machine,
	# and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
	#
	# Most users should NEVER change this value after the initial install, for any reason,
	# even if you've upgraded your system to a new NixOS release.
	#
	# This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
	# so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
	# to actually do that.
	#
	# This value being lower than the current NixOS release does NOT mean your system is
	# out of date, out of support, or vulnerable.
	#
	# Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
	# and migrated your data accordingly.
	#
	# For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
	system.stateVersion = "25.05"; # Did you read the comment?

	# HARDWARE

	hardware.enableRedistributableFirmware = true;

	boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
	boot.initrd.kernelModules = [ ];
	boot.kernelModules = [ "kvm-amd" ];
	boot.extraModulePackages = [ ];

	fileSystems."/" =
		{ device = "/dev/disk/by-uuid/3ad17340-7122-4887-983d-09ab4d7cccdd";
			fsType = "btrfs";
		};

	fileSystems."/boot" =
		{ device = "/dev/disk/by-uuid/C65C-15B2";
			fsType = "vfat";
			options = [ "fmask=0022" "dmask=0022" ];
		};

	swapDevices = [ ];

	nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
	hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

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
}
