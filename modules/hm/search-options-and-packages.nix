{ config, lib, pkgs, ... }: let
	bins = pkgs |> lib.mapAttrs (_: lib.getExe);

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

	packages = cfgs |> lib.mapAttrs (name: cfg: let
		cfgFile = pkgs.writeTextFile {
			name = "nix-search-${name}-cfg";
			text = builtins.toJSON <| cfg // {
				enable_waiting_message = false;
				cache_dir = config.xdg.cacheHome + "/nix-search-tv-wrappers/" + name;
			};
		};

		wrapper = cmd: ''${bins.nix-search-tv} ${cmd} --config "${cfgFile}"'';
	in
		pkgs.writeShellScriptBin "search-${name}" ''
			${wrapper "print"} | ${bins.fzf} --preview '${wrapper "preview {}"}'
		''
	);
in {
	options.programs.nix-search = lib.foldr lib.recursiveUpdate {} [
		(
			packages |> lib.mapAttrs (_: p: lib.mkOption {
				type = with lib.types; (submodule {
					options = {
						enable = lib.mkEnableOption "enable" // {
							default = config.programs.nix-search.enable;
						};
						package = lib.mkOption {
							type = lib.types.package;
							default = p;
						};
					};
				});
			})
		)
		{
			enable = lib.mkEnableOption "nix-search";
		}
	];

	config = {
		home.packages = packages
			|> lib.attrNames
			|> map (x: config.programs.nix-search.${x})
			|> lib.filter (x: x.enable)
			|> map (x: x.package)
		;
	};
}
