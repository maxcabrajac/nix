{ pkgs, inputs, ... }: {
	# TODO: Add an enable for this
	programs.steam.package = pkgs.steam.override {
		extraEnv.LD_AUDIT = let
			inherit (inputs.greenluma.packages.${pkgs.stdenv.hostPlatform.system}) sls-steam;
		in
			"${sls-steam}/library-inject.so:${sls-steam}/SLSsteam.so";
	};
}
