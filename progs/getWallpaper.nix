{ config, ... }: {
	programs.getWallpaper.dir = config.home.homeDirectory + "/Pictures/Wallpapers";
}
