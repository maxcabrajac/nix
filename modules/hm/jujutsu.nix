{ lib, config, ... }: let
	cfg = config.programs.jujutsu;
	cfgDir = "${config.xdg.configHome}/jj";
in {
	home.file = lib.mkIf (cfg.enable && cfg.settings != {})  {
		"${cfgDir}/config.toml".target = "${cfgDir}/conf.d/hm-managed.toml";
	};
}
