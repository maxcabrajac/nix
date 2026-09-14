{ config, inputs, ... }: {
	userAliases.max = [ "maximilian.cabrajac" ];
	user."max#work" = let
		enable = { enable = true; };
	in
		{ pkgs, ... }: {
			imports = [
				config.user.max
				config.hm.aws
				config.hm.aws_profile
			];
			targets.genericLinux = enable;
			terminal = enable;
			programs = {
				fish = enable;
				awscli = enable // {
					aws_profile.filters = [
						"sre-1"
						"sre-0"
					];
				};
				kubectl = enable;
			};

			home = {
				packages = with pkgs; [
					# management
					kubernetes-helm
					terraform
					sops
					gnumake

					# langs
					uv
					poetry
					go

					# misc
					jq
					yq-go
					# See users/max/_legacy/social.nix
					inputs.telegram-nixpkgs.legacyPackages.${pkgs.stdenv.targetPlatform.system}.telegram-desktop
					codex
				];

				shellAliases.ghi = "ggh inloco";
				sessionPath = [ "$HOME/.local/bin" ];

			};

			# Work ssh keys are managed manually
			sshKey = false;
		};
}
