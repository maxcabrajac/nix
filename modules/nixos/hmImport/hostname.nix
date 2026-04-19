{ config, ... }: {
	hmImport = [
		{
			path = [ "name" ];
			value = config.system.nixos.distroId;
		}
	];
}
