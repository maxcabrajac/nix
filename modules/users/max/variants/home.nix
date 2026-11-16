{ config, ... }: {
	user."max#home".imports = [
		config.user.max
		config.hm.termfilechooser
	];
}
