{ lib, config, maxLib, ... }: {
	options = {
		dbg = lib.mkOption {
			type = with lib.types; attrsOf anything;
			default = {};
		};
	};

	config = {
		home.packages = if config.dbg == {} then [] else lib.traceSeq (maxLib.prettyString config.dbg) [];
	};
}
