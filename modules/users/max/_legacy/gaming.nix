{ pkgs, lib, config, ...}: lib.mkIf config.profiles.games {
	home.packages = with pkgs; [
		heroic
		gamescope
		prismlauncher
	];

	# See https://forums.developer.nvidia.com/t/opengl-shader-disk-cache-max-size-garbage-collection/60056#5281950
	home.sessionVariables.__GL_SHADER_DISK_CACHE_SKIP_CLEANUP = 1;

	web.sites = [
		{
			alias = "lv";
			name = "H-group Conventions";
			bookmark = "hanabi.github.io/learning-path#level-summary";
			search_engine = "hanabi.github.io/level-%%";
		}
	];
}
