{ lib, inputs, ... }: {
	user.helo = { pkgs, ... }: {
		# TODO: get theme name from stylix
		services.awww.rngLoop.dir = inputs.wallpkgs.wallpapers.everforest
			|> lib.attrsets.collect (x: x ? path)
			|> map ({ hash, path, ... }: { name = hash; inherit path; })
			|> pkgs.linkFarm "wallpaper-dir"
		;
	};
}
