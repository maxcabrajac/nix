{ maxLib, ...}: {
	imports = maxLib.nonDefaultNix ./.;

	programs.fish = {
		shellInit = ''
			alias rbt "reboot"
			alias rr "lfcd"
			alias sdn "shutdown now"
			alias tmux "tmux -f ~/.config/tmux/tmux.conf"
			alias vim "nvim"

			set -p fish_function_path ~/.config/fish/prompt

		'';
	};
}
