{ config, pkgs, lib, ... }: {
	options.news.package = lib.mkOption {
		type = lib.types.package;
		readOnly = true;
	};

	config = {
		news.package = let
			json = "${config.news.json.output}";
		in pkgs.writeShellScriptBin "hm-news" ''
			${lib.getExe pkgs.jq} -r '
				.entries
				| sort_by(.time)
				| reverse
				| .[]
				| "\(80*"-")\n\n\(.time)\(if .condition then "" else " [UNUSED]" end)\n\(.message)"
			' ${json} | $PAGER
		'';

		home.packages = [ config.news.package ];
	};
}
