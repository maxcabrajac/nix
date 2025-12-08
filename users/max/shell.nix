{ pkgs, lib, ... }: {
	home.shellAbbrs = {
		af = "touch";
		k = "kubectl";
	};

	home.shellAliases = {
		rr = "lfcd";
		sdn = "shutdown now";
		rbt = "reboot";
	};

	home.packages = with pkgs; [
		nh
		nix-output-monitor
	];

	programs.nix-search.pkg.enable = true;
	programs.starship = {
		enable = true;

		settings = {

			format = lib.concatLines [
				"[┌$sudo](bold green) $directory"
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
