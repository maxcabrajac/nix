{ lib, config, pkgs, ...}: let
	cfg = config.programs.fish;
	file = "/tmp/fish_kept_dir";
in {
	programs.fish = {
		# functions.keep_dir = {
		# 	body = "set -U kept_dir $PWD";
		# 	onEvent = "fish_prompt";
		# };
		# The above doesn't work, falling back to inlineing
		shellInit = /*fish*/''
			function keep_dir --on-event fish_prompt
				echo ''$PWD > ${file}
			end
		'';

		shellAliases.cdd = /*fish*/''test -f "${file}" && builtin cd (cat ${file})'';
		interactiveShellInit = "cdd";
	};
}
