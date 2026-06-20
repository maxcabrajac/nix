{ pkgs, lib, config, ... }: let
	cfg = config.programs.git-manager;
in {
	options.programs.git-manager = {
		enable = lib.mkEnableOption "git-manager";
		cloner = lib.mkOption {
			type = lib.types.str;
		};
		root = lib.mkOption {
			type = lib.types.nullOr lib.types.str;
			default = null;
		};
		name = lib.mkOption {
			type = lib.types.str;
			default = "gm";
		};
	};

	config = let
		gm = pkgs.writeShellApplication {
			name = "git-manager";
			runtimeInputs = [
				pkgs.coreutils
			];
			runtimeEnv = {
				inherit (cfg) root cloner;
			} |> lib.filterAttrs (_: v: v != null);
			text = builtins.readFile ./script.sh;
		};
	in {
		home.packages = [gm];
		programs.fish.functions.${cfg.name} = {
			body = ''
				if set dir (${lib.getExe gm} ''$argv)
					cd $dir
				end
			'';
		};
	};
}
