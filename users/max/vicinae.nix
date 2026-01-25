{ pkgs, inputs, config, ... }: let
	inherit (inputs) vicinae-extensions;
	inherit (config.lib.vicinae) mkExtension;
in {
	programs.vicinae = {
		enable = true;
		systemd.enable = true;
		extensions = [
			(mkExtension { name = "process-manager"; src = vicinae-extensions + "/extensions/process-manager"; })
		];
	};
}
