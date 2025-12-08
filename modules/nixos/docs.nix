{ config, util, ... }: let
	module = isHm: { options, config, pkgs, lib, ... }: {
		options = {
			docs = lib.mkOption {
				type = with lib.types; attrsOf raw;
			};
		};

		config = let
			prefix = if isHm then [ "home-manager" "users" config.home.username ] else [];
			stripListPrefix = prefix: list: let
				prefixLen = builtins.length prefix;
			in
				if lib.take prefixLen list == prefix
				then lib.drop prefixLen list
				else list
			;
		in {
			docs.self = pkgs.nixosOptionsDoc {
				inherit options pkgs;
				warningsAreErrors = false;
				transformOptions = opt: opt // rec {
					loc = stripListPrefix prefix opt.loc;
					name = lib.concatStringsSep "." loc;
				};
			};
		};
	};
in {
	imports = [ (module false) ];
	home-manager.sharedModules = [
		(module true)
		# import os docs into HM
		{ docs.os = config.docs.self; }
	];
}
