{ lib, config, pkgs, ... }: let
	cfg = config.programs.jujutsu;
	cfgDir = "${config.xdg.configHome}/jj";
in
	lib.mkIf cfg.enable {
		home.file = lib.mkIf (cfg.settings != {})  {
			"${cfgDir}/config.toml".target = "${cfgDir}/conf.d/hm-managed.toml";
		};

		xdg.configFile.jujutsu-dynamic-fish-completions = {
			target = "fish/completions/jujutsu.fish";
			source = pkgs.runCommand "jj-dynamic-fish-completions" { nativeBuildInputs = [ pkgs.jujutsu ]; } ''
				COMPLETE=fish jj > $out
			'';
		};
	}
