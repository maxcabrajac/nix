{ lib, pkgs, inputs, ... }: {
	services.awww.rngLoop = {
		dir = inputs.wallpkgs.wallpapers
			|> lib.attrsets.collect (x: x ? path)
			|> map ({ hash, path, ... }: { name = hash; inherit path; })
			|> pkgs.linkFarm "wallpaper-dir"
		;
		# This is stupid
		fps = 120;
	};
}
