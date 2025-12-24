{ lib, config, pkgs, ... }: {
	programs.elephant.provider.websearch.settings = {
		history = false;
		command = pkgs.writeShellScript "walker_websearch_helper" ''
			${lib.getExe pkgs.notify-send} "$@"
			IFS=";" read -r -a parts <<< "$@"
			if [ -z "''${parts[2]}" ]; then
				url=''${parts[0]}
			else
				url=''${parts[1]//%%/''${parts[2]}}
			fi
			${lib.getExe pkgs.notify-send} $url
			exec ${pkgs.xdg-utils}/bin/xdg-open http://$url
		'';

		entries = let
			default_entry = {
				name = "Google";
				prefix = "g ";
				url = "google.com;google.com;%TERM%";
				default = true;
			};

			entries = config.web.sites
			|> map ({ name, alias, bookmark, search_engine }: {
				name = "${alias} (${name})";
				prefix = "${alias}";
				url = "${bookmark};${if isNull search_engine then bookmark else search_engine};%TERM%";
			});
		in
			entries ++ [default_entry];
		};
}
