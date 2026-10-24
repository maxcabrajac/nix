{
	host.hllzr = {
		services.pipewire.wireplumber.extraConfig.fixVolumeControl = {
			"monitor.alsa.rules" = [
				{
					matches = [{
						"device.name" = "alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic";
					}];
					actions.update-props = {
						"api.alsa.soft-mixer" = true;
					};
				}
			];
		};
	};
}
