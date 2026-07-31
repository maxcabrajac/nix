{
	description = "Nix Config";

	inputs = {
		nixpkgs.url = "nixpkgs/nixos-unstable";

		flake-parts.url = "github:hercules-ci/flake-parts";
		fp-devshell = {
			url = "github:numtide/devshell";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		systems.url = "github:nix-systems/default-linux";

		home-manager = {
			url = "github:nix-community/home-manager";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		niri-flake = {
			url = "github:sodiboo/niri-flake";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		mabar = {
			url = "github:maxcabrajac/mabar";
			inputs.nixpkgs.follows = "nixpkgs";
			inputs.systems.follows = "systems";
			inputs.flake-parts.follows = "flake-parts";
		};

		xdp-git = {
			url = "github:flatpak/xdg-desktop-portal/1.21.1";
			flake = false;
		};

		# this is HUGE
		wallpkgs.url = "github:NotAShelf/wallpkgs";

		elephant = {
			url = "github:maxcabrajac/elephant/websearch";
			inputs.nixpkgs.follows = "nixpkgs";
			inputs.systems.follows = "systems";
		};
		walker = {
			url = "github:abenz1267/walker/v2.15.2";
			inputs.elephant.follows = "elephant";
			inputs.nixpkgs.follows = "nixpkgs";
			inputs.systems.follows = "systems";
		};

		cachy-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

		nvf = {
			url = "github:NotAShelf/nvf";
		};

		# max-nvim
		nvim-ayu = { url = "github:Luxed/ayu-vim"; flake = false; };

		greenluma = {
			url = "github:AceSLS/SLSsteam";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		sops-nix = {
			url = "github:mic92/sops-nix";
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};

	nixConfig = {
		extra-experimental-features = [
			"pipe-operators"
		];

		extra-substituters = [
			"https://walker-git.cachix.org"
			"https://attic.xuyh0120.win/lantian" # cachy-kernel
		];

		extra-trusted-public-keys = [
			"walker-git.cachix.org-1:vmC0ocfPWh0S/vRAQGtChuiZBTAe4wiKDeyyXM0/7pM="
			"lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc=" # cachy-kernel
		];
	};

	outputs = inputs@{ flake-parts, nixpkgs, home-manager, ... }: let
		lib = nixpkgs.lib // home-manager.lib;
		util = import ./util {
			inherit lib inputs;
		};
	in
		flake-parts.lib.mkFlake { inherit inputs; } {
			imports = lib.flatten [
				inputs.fp-devshell.flakeModule
				inputs.home-manager.flakeModules.home-manager
				(util.allNixFiles ./flake)
			];

			_module.args = {
				inherit util;
			};

			altPkgs = {
			};

			dirs = {
				hosts = ./hosts;
				modules = ./modules;
				packages = ./pkgs;
				users = ./users;
			};

			systems = import inputs.systems;
			flake = {
				inherit util inputs;
				homeModules = {
					inherit (inputs.sops-nix.homeManagerModules) sops;
				};
			};

			perSystem = { pkgs, ... }: let
				# Convert { a.b.c = 1; } into { b = { key = a; c = 1; }; }
				injectKeys = key: attrs: let
					setKeyTo = value: attr: attr // { "${key}" = value; };
					injector = lib.mapAttrs (keyValue: lib.mapAttrs (_: setKeyTo keyValue));
				in
					lib.mergeAttrsList (lib.attrValues (injector attrs))
				;
				namedList = attr: lib.attrValues (lib.mapAttrs (name: v: v // { inherit name; }) attr);
			in {
				devshells.default = {
					motd = "$(type -p menu &> /dev/null && echo Use $(tput bold)menu$(tput sgr0) to list useful commands)";

					packages = with pkgs; [
						nh
						dix
						sops
						jq
						bitwarden-cli
						ssh-to-age
					];
					commands = namedList (injectKeys "category" {
						"[OS]" = {
							os-switch.command = "nh os switch $PRJ_ROOT -a";
							os-test.command = "nh os test $PRJ_ROOT";
							os-boot.command = "nh os boot $PRJ_ROOT";
							os-diff.command = /* bash */ ''
								if ! [ -e /run/current-system ]; then
									echo "Error: /run/current-system does not exist."
									exit 1
								fi

								current_drv=$(nix-store --query --deriver $(realpath /run/current-system))
								next_drv=$(nix --no-warn-dirty eval $PRJ_ROOT#nixosConfigurations.$(hostname).config.system.build.toplevel.drvPath --raw)
								dix $current_drv $next_drv
							'';
						};
						"[HM]" = {
							hm-switch.command = ''
								variant=''${1-''${HOME_MANAGER_VARIANT-default}}
								nh home switch $PRJ_ROOT -a -c "''${USER}#''${variant}@$(uname -m)-linux"
							'';
						};
						"[general commands]" = {
							update.command = "cd $PRJ_ROOT && nix flake update";
							sops-init.command = ''
								if ! [ -n "''${BW_SESSION+is_set}" ]; then
									export BW_SESSION="$(bw login --raw || bw unlock --raw)"
								fi
								bw sync

								SECRET_NAME="sops-nix age"

								function query() {
									jq --arg name "$SECRET_NAME" "$@"
								}

								KEY="$(bw list items --search "$SECRET_NAME" | query 'map(select(.name == $name))')"
								if $(echo "$KEY" | query 'length == 0'); then
									echo "No key on bitwarden"
									exit 1
								fi
								KEY="$(echo "$KEY" | query '.[0].sshKey')"

								PK="$(echo "$KEY" | query -r '.privateKey')"
								PUB="$(echo "$KEY" | query -r '.publicKey')"

								AGE_PK=$(echo "$PK" | ssh-to-age -private-key)
								OUT="$HOME/.config/sops/age/keys.txt"
								mkdir -p "$(dirname "$OUT")"
								touch "$OUT"
								if ! grep -q "$AGE_PK" "$OUT"; then
									echo "$AGE_PK" >> "$OUT"
								fi
								echo Your pub key is:
								echo "$PUB" | ssh-to-age
							'';
						};
					});
				};
			};
	};
}
