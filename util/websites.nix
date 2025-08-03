{ lib, util, ... }: let
	inherit (lib)
		mkOption
		toLower
		types
	;
in {
	types.web = with types; rec {
		search_engine = strMatching ".*%%.*";
		site = submodule ({config, ...}: {
			options = {
				name = mkOption {
					type = str;
				};
				alias = mkOption {
					type = str;
					default = toLower config.name;
				};
				bookmark = mkOption {
					type = str;
				};
				search_engine = mkOption {
					type = nullOr search_engine;
					default = null;
				};
			};
		});
	};
}
