{ pkgs, lib, ...}: let
	bins = lib.mapAttrs (_: p: lib.getExe p) pkgs;
in {
	programs.lf = {
		enable = true;

		settings = {
			findlen = 2;
			mouse = true;
			tabstop = 3;
		};

		commands = {
			open = ''$ $OPENER "$f"'';

			mkdir = ''%mkdir -p "$@"'';
			touch = ''%touch "$@"'';

			tar-compress = "%{{ realpath --relative-to=$PWD $fx | xargs ${bins.gnutar} czf $@.tar.gz }}";
			tar-extract = ''%${bins.gnutar} xzf "$f"'';
			zip-compress = "%{{ realpath --relative-to=$PWD $fx | xargs ${bins.zip} -r $@.zip }}";
			zip-extract = ''%${bins.unzip} "$f"'';
		};

		keybindings = {
			D = "delete";

			k = "search-next";
			K = "search-prev";

			e = "up";
			n = "down";
			i = "open";

			ad = "push :mkdir<space>";
			af = "push :touch<space>";

			gd = "cd ~/Downloads";

			t = null;
			tc = "push :tar-compress<space>";
			te = ":tar-extract; reload";

			z = null;
			zc = "push :zip-compress<space>";
			ze = ":zip-extract; reload";
		};

		lfcd = true;
	};
	home.shellAliases.rr = "lfcd";
}
