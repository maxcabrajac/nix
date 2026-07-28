{ config, lib, ... }: let
	inherit (lib) mkOption types;
	inherit (types) attrsOf submodule nullOr;
in {
	options = {
		secretFiles = mkOption {
			type = attrsOf (submodule {
				options = {
					enable = mkOption {
						type = types.bool;
					};
					src = mkOption {
						type = types.pathInStore;
					};
					dest = mkOption {
						type = nullOr types.externalPath;
						default = null;
					};
					mode = mkOption {
						type = nullOr types.str;
						default = null;
					};
				};
			});
			default = {};
		};
	};

	config = {
		sops = {
			age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
			secrets = config.secretFiles
				|> lib.filterAttrs (_: attr: attr.enable)
				|> lib.mapAttrs (_: { src, dest, mode, ... }: {
					sopsFile = src;
					format = "binary";
					path = lib.mkIf (dest != null) dest;
					mode = lib.mkIf (mode != null) mode;
				})
			;
		};
	};
}
