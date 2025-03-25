{...}: rec {
	homeManagerModule = { lib, pkgs, config, ... }: let
		cfg = config.programs.abcd;
	in {
		options.programs.abcd = {
			enable = lib.mkEnableOption "abcd";
			package = lib.mkOption {
				type = lib.types.package;
				default = pkgs.abcd or (packages pkgs).abcd;
			};
			enableFishIntegration = lib.mkOption {
				type = lib.types.bool;
				default = config.home.shell.enableFishIntegration;
			};
		};

		config = lib.mkIf cfg.enable {
			home.packages = [ cfg.package ];

			programs.fish.functions = lib.mkIf cfg.enableFishIntegration {
				cd = {
					body = let abcd = lib.getExe cfg.package; in /*fish*/ ''
						switch $argv[1]
							case "."
								${abcd} add
							case ".."
								${abcd} remove
								builtin cd ..
							case ""
								set dir (${abcd} find)
								set ret $status
								if test $ret -eq 0
									builtin cd $dir
									return
								end
								builtin cd $HOME
							case "*"
								builtin cd $argv
						end
					'';
					wraps = "cd";
				};
			};
		};
	};

	packages = pkgs: {
		abcd = pkgs.makeScript { inherit pkgs; } ./abcd.sh;
	};
}
