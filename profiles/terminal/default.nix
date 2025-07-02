{ pkgs, lib, config, maxLib, ... }: let
	enable = { enable = true; };
in {
	imports = maxLib.nonDefaultNix ./.;

	options.profile.terminal = lib.mkEnableOption "Terminal Profile";

	config = lib.mkIf config.profile.terminal {
		programs = {
			lf = enable;
			abcd = enable;
			fish = enable;
			jujutsu = enable;
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
			nn = "jj";
		};

		home.shellAbbrs = {
			af = "touch";
			ad = "mkcd";
			e = "editor";
			z = "zathura";
			k = "kubectl";
		};

		home = {
			packages = with pkgs; [
				neovim
			];
		};
	};
}
