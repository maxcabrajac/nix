variant: { options, config, pkgs, lib, ... }: {
	options = {
		docs = lib.mkOption {
			type = with lib.types; attrsOf raw;
		};
	};

	config = let
		prefix = if (variant == "hm") then [ "home-manager" "users" config.home.username ] else [];
		stripListPrefix = prefix: list: let
			prefixLen = builtins.length prefix;
		in
			if lib.take prefixLen list == prefix
			then lib.drop prefixLen list
			else list
		;
	in
		lib.mkMerge [
			{
				docs.self = pkgs.nixosOptionsDoc {
					inherit options pkgs;
					warningsAreErrors = false;
					transformOptions = opt: opt // rec {
						# Remove declarations so it doesn't bloat the output
						declarations = [];

						loc = stripListPrefix prefix opt.loc;
						name = lib.concatStringsSep "." loc;
					};
				};
			}
			(lib.optionalAttrs (variant == "os") {
				home-manager.sharedModules = [
					{ docs.os = config.docs.self; }
				];
			})
		];
}
