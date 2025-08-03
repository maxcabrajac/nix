{...}: rec {
	safeArg = (f: builtins.intersectAttrs (builtins.functionArgs f));
	safeCall = (f: arg: f (safeArg f arg));
}
