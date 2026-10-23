{ inputs, ... }: {
	user.helo = { pkgs, ... }: {
		imports = [ inputs.stylix.homeModules.stylix ];

		stylix = {
			enable = true;
			base16Scheme = "${pkgs.base16-schemes}/share/themes/everforest.yaml";
			# TODO: Add this back
			# image = ./wallpapers/forest_stairs.jpg;
			overlays.enable = false;
		};
	};
}
