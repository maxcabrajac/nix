{ config, ... }: {
	user.max.imports = with config.hm; [
		fish-auto-ls
		fish-keep-dir
		git-manager
	];
}
