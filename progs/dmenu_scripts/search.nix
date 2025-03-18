{ pkgs, lib, maxLib, config, helpers, ... }: with lib; let
	cfg = config.programs.dmenu_scripts;
	search_engines = pipe config.global.web.sites [
		(map ({alias, name, bookmark, search_engine,...}:
			nameValuePair alias { inherit name bookmark search_engine; })
		)
		listToAttrs
	];
	spec = {
		env = {
			DMENU = getExe cfg.dmenu;
			engines = strings.toJSON search_engines;
			default_engine = config.global.web.default_search_engine;
		};
	};
	script = maxLib.makeScriptInject spec { inherit pkgs helpers; } ./scripts/search.bash;
in mkIf cfg.enable {
	global.keybinds = [ { mods = "M"; key = "O"; cmd = with script; "$BROWSER $(${getExe search})"; } ];
}
