{ lib, maxLib, ...}: let
	inherit (lib.fixedPoints) fix;
	inherit (maxLib) mapDir;
in rec {
	homeManagerModule = { pkgs, lib, config, ...}: let
		cfg = config.programs.getWallpaper;
	in {
		options.programs.getWallpaper = {
			package = lib.mkOption {
				type = lib.types.package;
				default = pkgs.getWallpaper or (packages pkgs).getWallpaper;
			};

			dir = lib.mkOption {
				type = lib.types.path;
			};

			configured_pkg = lib.mkOption {
				type = lib.types.package;
			};
		};

		config = {
			programs.getWallpaper.configured_pkg = pkgs.writers.writeDashBin
				"getWallpaper"
				/*dash*/''WALLPAPER_DIR=${cfg.dir} ${lib.getExe cfg.package} "''$@"'';
		};
	};

	packages = pkgs: fix (self:
		mapDir (pkgs.makeScript { inherit self pkgs; }) ./scripts
	);
}
