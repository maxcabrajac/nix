{ lib, config, pkgs, ... }: {
	options.programs.awscli.aws_profile = {
		enable = lib.mkEnableOption "" // {
			default = true;
		};

		filters = lib.mkOption {
			type = lib.types.uniq <| lib.types.listOf lib.types.str;
			default = [];
		};
	};

	config = let
			cfg = config.programs.awscli;
			aws = lib.getExe cfg.package;
			fzf = lib.getExe pkgs.fzf-funnel;
		in lib.mkIf (cfg.enable && cfg.aws_profile.enable) {
			programs.fish.functions.aws_profile = {
				body = /* fish */ ''
					${aws} configure list-profiles | ${fzf} ${lib.escapeShellArgs cfg.aws_profile.filters} -- $argv | read profile
					if test -n profile
						set -Ux AWS_PROFILE "$profile"
						echo "Now using $(set_color brgreen)$profile$(set_color normal) across all fish shells"
					else
						echo "No profile selected"
						return 1
					end
				'';
			};
		};
}
