{ modulesPath, inputs, lib, config, pkgs, ... }: let
	inherit (inputs) anyrun;
	anyrunPkgs = anyrun.packages.${pkgs.stdenv.hostPlatform.system};
	cfg = config.programs.anyrun;
in {
	disabledModules = ["${modulesPath}/programs/anyrun.nix"];
	imports = [ inputs.anyrun.homeManagerModules.default ];

	options.programs.anyrun = {
		config.upstreamPlugins = lib.mkOption {
			type = with lib.types; attrsOf bool;
			default = {};
		};
	};

	config = lib.mkMerge [
		{
			programs.anyrun = {
				daemon.enable = true;
				config.height = lib.mkDefault { absolute = 1; };
			};
		}
		(lib.mkIf (cfg.enable && cfg.config.upstreamPlugins != {}) (let
			upstreamPlugins = anyrunPkgs
				|> lib.attrNames
				|> lib.filter (x: x != "default")
				|> lib.filter (x: ! lib.hasPrefix "anyrun" x)
			;
		in {
			assertions = cfg.config.upstreamPlugins
				|> lib.attrNames
				|> map (name: {
					assertion = builtins.elem name upstreamPlugins;
					message = lib.concatLines <| lib.flatten [
						"No anyrun upstream plugin named: ${name}."
						"Anyrun exposed packages:"
						(upstreamPlugins |> map (x: "  - ${x}"))
					];
				})
			;

			# FIXME: Use this whenever anyrun's cachix instance works
			# programs.anyrun.config.plugins = cfg.config.upstreamPlugins
			# 	|> lib.filterAttrs (_: enable: enable)
			# 	|> lib.attrNames
			# 	|> map (name: anyrunPkgs.${name})
			# ;

			programs.anyrun = {
				package = anyrunPkgs.anyrun-with-all-plugins;
				config.plugins = cfg.config.upstreamPlugins;
			};
		}))
	];
}
