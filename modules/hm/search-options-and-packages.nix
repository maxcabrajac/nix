{ inputs, config, lib, pkgs, ... }: let
	bins = pkgs |> lib.mapAttrs (_: lib.getExe);
	toCfgFile = name: cfg: pkgs.writeTextFile {
		name = "nix-search-${name}-cfg";
		text = builtins.toJSON cfg;
	};

	cfgs = {
		opt = {
			indexes = [];
			experimental.options_file = config.docs |> lib.mapAttrs' (name: value: {
				name = if name == "self"
					then "hm"
					else name;
				value = value.optionsJSON + "/share/doc/nixos/options.json";
			});
		};
		pkg = {
			indexes = [ "nixpkgs" ];
		};
	};

	cfgFor = name: {
		enable_waiting_message = false;
		cache_dir = config.xdg.cacheHome + "/nix-search-tv-wrappers/" + name;
	};

	backends = cfgs |> lib.mapAttrs (name: base_cfg: let
		cfg = base_cfg // (cfgFor name);
	in cmd:
		''${bins.nix-search-tv} ${cmd} --config "${toCfgFile name cfg}"''
	);

	cmdModule = with lib.types; { config, ... }: {
		options = {
			enable = lib.mkEnableOption "enable";
			name = lib.mkOption {
				type = str;
				internal = true;
			};
			cmd = lib.mkOption {
				type = str;
				internal = true;
			};
			package = lib.mkOption {
				type = package;
				readOnly = true;
			};
			indirect = lib.mkOption {
				type = bool;
				default = false;
			};
			optionPath = lib.mkOption {
				type = str;
			};
			finalPackage = lib.mkOption {
				type = package;
				readOnly = true;
			};
		};

		config = let
			writeScript = pkgs.writeShellScriptBin "search-${config.name}";
		in {
			package = writeScript config.cmd;
			finalPackage =
				if config.indirect
				then writeScript ''
						PATH=${lib.makeBinPath [ pkgs.coreutils pkgs.hostname pkgs.nix ]}
						nix run "${inputs.self.outPath}#homeConfigurations.''$(whoami)@''$(hostname).config.${config.optionPath}.package"
				''
				else config.package
			;
		};
	};
in {
	options.programs.nix-search = lib.foldr lib.recursiveUpdate {} [
		(
			backends |> lib.mapAttrs (_: _: lib.mkOption {
				type = with lib.types; (submodule cmdModule);
			})
		)
		{
			enable = lib.mkEnableOption "nix-search";
		}
	];

	config = {
		programs.nix-search = backends |> lib.mapAttrs (name: backend: {
			enable = lib.mkDefault config.programs.nix-search.enable;

			inherit name;
			optionPath = "programs.nix-search.${name}";
			indirect = name == "opt";
			cmd = ''${backend "print"} | ${bins.fzf} --preview '${backend "preview {}"}' --scheme history'';
		});

		home.packages = backends
			|> lib.attrNames
			|> map (x: config.programs.nix-search.${x})
			|> lib.filter (x: x.enable)
			|> map (x: x.finalPackage)
		;
	};
}
