{ lib, inputs, ... }: {
	packages.hm-news = {
		writeShellScriptBin,
		writeText,
		jq,
		pkgs,
		entries ? null,
		entryFormat ? ''"\(80*"-")\n\n\(.time)\n\(.message)"''
		# entryFormat? ''z\(80*"-")\n\n\(.time)\(if .condition then "" else " [UNUSED]" end)\n\(.message)''
	}:
		let
			defaultEntries = inputs.home-manager.lib.homeManagerConfiguration {
				inherit pkgs;
				modules = [{
					home = {
						stateVersion = "26.11";
						username = "nobody";
						homeDirectory = "/home/nobody";
					};
				}];
			} |> (x: x.config.news.entries);
			finalEntries =
				if isNull entries
				then defaultEntries
				else entries
			;
			entriesJson = writeText "hm-news.json" <| builtins.toJSON finalEntries;
		in
			writeShellScriptBin "hm-news" ''
				${lib.getExe jq} -r '
					sort_by(.time)
					| reverse
					| .[]
					| ${entryFormat}
				' ${entriesJson} | $PAGER
			''
		;

	hm.base = { config, withSystem, ... }: {
		options.news = {
			package = lib.mkOption {
				type = lib.types.package;
				readOnly = true;
			};
			entryFormat = lib.mkOption {
				type = lib.types.str;
				default = ''"\(80*"-")\n\n\(.time)\(if .condition then "" else " [UNUSED]" end)\n\(.message)"'';
			};
		};

		config = {
			news.package = withSystem.packages.hm-news.override {
				inherit (config.news) entries entryFormat;
			};

			home.packages = [ config.news.package ];
		};
	};
}
