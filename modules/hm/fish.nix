{ pkgs, lib, util, config, ... }: let
	inherit (lib)
		attrsToList
		concatLines
		map
		mkEnableOption
		mkIf
		mkOption
		types
	;

	cfg = config.programs.fish;
in
	[
		{
			options.programs.fish.autols = lib.mkEnableOption "autols";
			config.programs.fish = mkIf cfg.autols {
				shellInit = /* fish */ ''
				set AUTOLS_DISABLE false
				function autols --on-variable PWD
					if ! ''$AUTOLS_DISABLE
						ls
					end
				end
				'';
			};
		}
		{
			options.programs.fish.keepDir = lib.mkEnableOption "keepDir";
			config.programs.fish = let file = "/tmp/fish_kept_dir"; in mkIf cfg.keepDir {
				shellAliases.cdd = /* fish */ ''test -f "${file}" && builtin cd (cat ${file})'';
				interactiveShellInit = /* fish */ ''
				function keep_dir --on-event fish_prompt
					pwd > ${file}
				end
				cdd
				'';
			};
		}
		{
			options.programs.fish = {
				sessionVariables = mkOption {
		  	  	  default = { };
		  	  	  type =
			 	 	 with types;
			 	 	 lazyAttrsOf (oneOf [
						str
						int
						path
			 	 	 ]);
				};
			};

			config.programs.fish.interactiveShellInit =
				cfg.sessionVariables
				|> attrsToList
				|> map ({ name, value }: ''set -x "${name}" "${builtins.toString value}"'')
				|> concatLines
			;
		}
		(lib.mkIf cfg.enable {
			xdg.configFile."fish/completions/nix.fish".source = "${pkgs.nix}/share/fish/vendor_completions.d/nix.fish";
		})
	] |> (mods: { imports = mods; })
