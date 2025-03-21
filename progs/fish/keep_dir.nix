{ lib, config, pkgs, ...}: let
	cfg = config.programs.fish;
	var = "kept_dir";
in {
	programs.fish = {
		# functions.keep_dir = {
		# 	body = "set -U kept_dir $PWD";
		# 	onEvent = "fish_prompt";
		# };
		# The above doesn't work, falling back to inlineing
		shellInit = /*fish*/''
			function keep_dir --on-event fish_prompt
				set -U ${var} "$PWD"
			end
		'';

		shellAliases.cdd = /*fish*/''set -q ${var} && test -d "''$${var}" && builtin cd "''$${var}"'';
		interactiveShellInit = "cdd";
	};

	systemd.user.services = lib.mkIf cfg.enable {
		clean-kept-dir = {
			Unit = {
				Description = "Clear fish kept_dir on log out";
			};

			Service = {
				RemainAfterExit = true;
				ExecStop = "${lib.getExe cfg.package} -c 'set -e -U ${var}'";
			};

			Install = {
				WantedBy = ["default.target"];
			};
		};
	};
}
