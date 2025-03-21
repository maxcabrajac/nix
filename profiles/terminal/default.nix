{ pkgs, lib, config, maxLib, ... }: let
	enable = { enable = true; };
	disable = { enable = false; };
in {
	imports = maxLib.nonDefaultNix ./.;

	options.profile.terminal = lib.mkEnableOption "Terminal Profile";

	config = lib.mkIf config.profile.terminal {
		programs = {
			lf = enable;
			abcd = enable;
			fish = enable;
		};

		home.shellAliases = {
			susp = "systemctl suspend";
			hib = "systemctl hibernate";
			clip = "xclip -selection clipboard";
			grep = "grep -in --color";
			less = "editor -p";
			ls = "exa --group-directories-first";
			lsa = "ls -a";
			mv = "mv -i";
			rm = "rm -d";
		};

		home.shellAbbrs = {
			af = "touch";
			ad = "mkcd";
			e = "editor";
			z = "zathura";
		};

		home = {
			packages = with pkgs; [
				neovim
			];
		};
	};
}
