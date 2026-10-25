{
	host.nixos = {
		services.pipewire.wireplumber.extraConfig.fixVolumeControl = {
			"monitor.alsa.rules" = [
				{
					matches = [{
						"device.name" = "alsa_card.usb-Kingston_HyperX_Cloud_Revolver_000000000001-00";
					}];
					actions.update-props = {
						"api.alsa.soft-mixer" = true;
					};
				}
			];
		};
	};
}
