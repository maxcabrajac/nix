{ lib, inputs, ... }:  {
	imports = [
		inputs.fp-devshell.flakeModule
	];

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
}
