{ lib, util, ... }: {
	hmModule = { pkgs, config, ... }: with lib; let
		cfg = config.programs.dmenu_scripts;
		pkgNames = pkgs.dmenu_scripts
			|> lib.attrNames
			|> filter (x: !(lib.strings.hasInfix "override" x))
		;
	in {
		options.programs.dmenu_scripts = with types; util.deepMerge [
			# General Options
			{
				enable = mkEnableOption "dmenu_scripts";

				dmenu = mkPackageOption pkgs "dmenu" {};

				metaPackage = mkPackageOption pkgs "dmenu_scripts" {} // {
					type = raw;
				};
			}
			# Common Options
			(
				lib.genAttrs pkgNames (_: {
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
			finalMetaPackage = cfg.metaPackage.override { dmenu = cfg.dmenu; };
			overrides = {
				search = {
					engines = cfg.search.engines
						|> map ({ alias, ... }@site: { name = alias; value = site; })
						|> listToAttrs
					;
					default_engine = cfg.search.default_engine;
				};
			};
		in {
			programs.dmenu_scripts = genAttrs pkgNames (pkgName: {
				package = finalMetaPackage.${pkgName}.override overrides.${pkgName};
			});

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

	packages.dmenu_scripts = {
		jq,
		gnused,
		coreutils,
		writeShellApplication,
		dmenu
	}: {
		search = (lib.flip lib.makeOverridable) {} ({
				engines ? {
					g = {
						bookmark = "google.com";
						search_engine = "google.com/search?q=%%";
					};
				},
				default_engine ? "google.com/search?q=%%"
			}: writeShellApplication {
				name = "dmenu_search";
				text = builtins.readFile ./scripts/search.bash;
				runtimeInputs = [ jq gnused coreutils ];
				excludeShellChecks = ["SC2089" "SC2090"];
				runtimeEnv = {
					inherit default_engine;
					engines = builtins.toJSON engines;
					DMENU = lib.getExe dmenu;
				};
				inheritPath = false;
			});
	};
}
