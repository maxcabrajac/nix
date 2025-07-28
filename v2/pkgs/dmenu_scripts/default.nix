{ lib, util, ... }: {
	hmModule = { pkgs, config, ... }: with lib; let
		cfg = config.programs.dmenu_scripts;
	in {
		options.programs.dmenu_scripts = with types; {
			enable = mkEnableOption "dmenu_scripts";

			dmenu = mkPackageOption null "dmenu" {
				nullable = false; default = null;
			};

			search = {
				enable = mkOption {
					type = types.bool;
					default = cfg.enable;
				};

				engines = mkOption {
					type = listOf util.types.web.site;
					default = [];
				};

				default_engine = mkOption {
					type = util.types.web.search_engine;
					default = "google.com/search?q=%%";
				};
			};
		};

		config = let
			envs = {
				search = {
					engines = cfg.search.engines |> map ({ alias, ... }@site: { name = alias; value = site; }) |> lib.listToAttrs |> builtins.toJSON;
					default_engine = cfg.search.default_engine;
				};
			};

			wrapped = name: let
				p = pkgs.dmenu_scripts.${name};
				exe = lib.getExe p;
				dmenu = lib.getExe cfg.dmenu;
			in
				pkgs.writers.writeDashBin p.meta.mainProgram (
					envs.${name}
					|> attrsToList
					|> map ({ name, value }: "export ${name}='${value}'")
					|> (lines: lines ++ [
						''export DMENU=${dmenu}''
						''exec ${exe} "$@"''
					])
					|> lib.concatLines
				);
		in {
			home.packages = lib.flatten [
				(lib.optional cfg.search.enable (wrapped "search"))
			];
		};
	};

	packages = { pkgs, ... }:
		./scripts
		|> pkgs.scriptDir { inherit pkgs; }
		|> lib.mapAttrs (name: p: pkgs.writers.writeDashBin "dmenu_${name}" ''exec ${lib.getExe p} "$@"'')
		|> (scripts: { dmenu_scripts = scripts; })
	;
}
