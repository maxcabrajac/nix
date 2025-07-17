{ lib, config, ... }: {
	home-manager = config.profiles.forEachUser "lf" {
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

				tar-compress = "%{{ realpath --relative-to=$PWD $fx | xargs tar czf $@.tar.gz }}";
				tar-extract = "%tar xzf $f";
				zip-compress = "%{{ realpath --relative-to=$PWD $fx | xargs zip -r $@.zip }}";
				zip-extract = "%unzip $f";
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
		};
	};
}
