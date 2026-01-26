{ pkgs, lib, ... }: {
	home.shellAbbrs = {
		af = "touch";
		k = "kubectl";
	};

	home.shellAliases = {
		sdn = "shutdown now";
		rbt = "reboot";
	};

	home.packages = with pkgs; [
		nh
		nix-output-monitor
		fzf
		zip
		unzip
	];

	programs.nix-search.pkg.enable = true;
	programs.starship = {
		enable = true;

		settings = {

			format = lib.concatLines [
				"[┌$sudo](bold green) $directory$fill\${custom.jj}"
				"[└$status](bold green)$character"
			];

			sudo = {
				disabled = false;
				style = "";
				format = "┤[sudo](bold bright-blue)├";
			};

			status = {
				disabled = false;
				format = "$symbol";
				style = "";
				success_symbol = "─";
				not_found_symbol = "─";
				symbol = "┤[$int](bold bright-red)├";
				map_symbol = true;
				signal_symbol = "┤[$signal_name](bold bright-blue)├";
				sigint_symbol = "┤[INT](bold bright-blue)├";
			};

			character = {
				success_symbol = "[>](bold green)";
				error_symbol = "[>](bold green)";
				vimcmd_symbol = "[|](bold blue)";
				vimcmd_replace_symbol = "[>](bold purple)";
				vimcmd_replace_one_symbol = "[|](bold purple)";
				vimcmd_visual_symbol = "[v](bold yellow)";
			};

			fill.symbol = " ";

			custom.jj = let
				jj = "${lib.getExe pkgs.jujutsu} --ignore-working-copy";
			in {
				when = "${jj} workspace root";
				command = pkgs.writeShellScript "jj-prompt" /* bash */ ''
					${jj} log -r @ --no-graph --color always --limit 1 --template '
						separate(" ",
							change_id.shortest(4),
							bookmarks,
							concat(
								if(conflict, "x"),
								if(divergent, "??"),
								if(hidden, "H"),
							),
							concat(
								raw_escape_sequence("\x1b[1;32m") ++ if(diff.stat().total_added() > 0, "+" ++ diff.stat().total_added()),
								raw_escape_sequence("\x1b[1;31m") ++ if(diff.stat().total_removed() > 0, "-" ++ diff.stat().total_removed()),
								raw_escape_sequence("\x1b[0m"),
							),
							raw_escape_sequence("\x1b[1;32m") ++ coalesce(
								truncate_end(29, description.first_line(), "…"),
								"(no description set)",
							) ++ raw_escape_sequence("\x1b[0m"),
						)
					'
				'';
			};
		};
	};

	programs.eza = {
		enable = true;
		extraOptions = [
			"--group-directories-first"
		];

		# TODO: Theme this?
		# theme = {};
	};
}
