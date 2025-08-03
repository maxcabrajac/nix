{ config, ... }: {
	boot = {
		kernelModules = [ "v4l2loopback" ];

		extraModulePackages = [
			config.boot.kernelPackages.v4l2loopback
		];

		# exclusive_caps: Skype, Zoom, Teams etc. will only show device when actually streaming
		# card_label: Name of virtual camera, how it'll show up in Skype, Zoom, Teams
		# https://github.com/umlaeute/v4l2loopback
		extraModprobeConfig = ''
			options v4l2loopback exclusive_caps=1 card_label="Virtual Camera"
		'';
	};
}
