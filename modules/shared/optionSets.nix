{ lib, ... }: let
	t = lib.types;
in {
	hm.base = { options, ... }: {
		options.optionSets = lib.mkOption {
			type = t.attrsOf t.raw;
			default = {};
		};

		config.optionSets.hm = let
			# When hm modules are use as part of nixos systems option names are prefixed with "home-manager.users.<username>"
			removeHmUsersPrefixFromOpt = opt: opt // lib.optionalAttrs (lib.lists.hasPrefix [ "home-manager" "users" ] opt.loc) {
				loc = lib.drop 3 opt.loc;
			};
			removeHmUsersPrefix = lib.mapAttrsRecursiveCond
				(as: !(as ? _type && as._type == "option"))
				(_: removeHmUsersPrefixFromOpt)
			;
		in
			options |> removeHmUsersPrefix
		;
	};

	# Inject os options from host
	os.base = { options, ... }: {
		home-manager.sharedModules = [{
			optionSets.os = options;
		}];
	};
}
