{ lib, util, ... }: {
	hmModule = { pkgs, config, ... }: with lib; let
		cfg = config.programs.dmenu_scripts;
		pkgNames = lib.attrNames pkgs.dmenu_scripts;
	in {
		options.programs.dmenu_scripts = with types; util.deepMerge [
			# General Options
			{
				enable = mkEnableOption "dmenu_scripts";

				dmenu = mkPackageOption null "dmenu" {
					nullable = false; default = null;
				};
			}
			# Common Options
			(
				lib.genAttrs pkgNames (pkgName: {
					enable = mkOption {
						type = bool;
						default = cfg.enable;
					};

					package = mkOption {
						type = package;
					};
				})
			)
			# Options by package
			{
				search = {
					engines = mkOption {
						type = listOf util.types.web.site;
						default = [];
					};

					default_engine = mkOption {
						type = util.types.web.search_engine;
						default = "google.com/search?q=%%";
					};
				};
			}
		];

		config = let
			envs = {
				search = {
					engines = cfg.search.engines
						|> map ({ alias, ... }@site: { name = alias; value = site; })
						|> listToAttrs
						|> builtins.toJSON
					;
					default_engine = cfg.search.default_engine;
				};
			};

			wrapped = pkgName: let
				p = pkgs.dmenu_scripts.${pkgName};
				exe = lib.getExe p;
				dmenu = lib.getExe cfg.dmenu;
			in
				pkgs.writers.writeDashBin p.meta.mainProgram (
					envs.${pkgName}
					|> attrsToList
					|> map ({ name, value }: "export ${name}='${value}'")
					|> (lines: lines ++ [
						''export DMENU=${dmenu}''
						''exec ${exe} "$@"''
					])
					|> concatLines
				);
		in {
			programs.dmenu_scripts = genAttrs pkgNames (pkgName: { package = wrapped pkgName; });

			home.packages = pkgNames
				|> map (
					pkgName: let
						subcfg = cfg.${pkgName};
					in
						mkIf subcfg.enable subcfg.package
				)
			;
		};
	};

	packages = { pkgs, ... }:
		./scripts
		|> pkgs.scriptDir { inherit pkgs; }
		|> lib.mapAttrs (name: p: pkgs.writers.writeDashBin "dmenu_${name}" ''exec ${lib.getExe p} "$@"'')
		|> (scripts: { dmenu_scripts = scripts; })
	;
}
