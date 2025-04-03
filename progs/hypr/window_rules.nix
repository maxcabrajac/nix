{ lib, pkgs, config, ... }: let
	cfg = config.programs.hypr;
in {
	options.programs.hypr = with lib; {
		windowRules = let
			rule = types.submodule ({ config, ... }: {
				options = {
					cmd = lib.mkOption {
						type = with types; functionTo str;
					};

					class = lib.mkOption {
						type = with types; nullOr str;
						default = null;
					};

					title = lib.mkOption {
						type = with types; nullOr str;
						default = null;
					};

					output = lib.mkOption {
						type = with types; functionTo str;
						internal = true;
					};
				};

				config = {
					output = window_id: pipe (config.cmd window_id) [
						(cmd: if isNull config.class
							then cmd
							else /*sh*/''if [[ "''$CLASS" =~ "${config.class}" ]]; then ${cmd}; fi ''
						)
						(cmd: if isNull config.title
							then cmd
							else /*sh*/''if [[ "''$TITLE" =~ "${config.title}" ]]; then ${cmd}; fi ''
						)
						(lib.throwIf ((isNull config.title) && (isNull config.class)) "No matchers for window rule: ${config.cmd "<wid>"}")
					];
				};
			});
		in mkOption {
			type = with types; listOf rule;
			default = [];
		};
	};

	config = let
		getField = lib.getExe pkgs.getField;

		windowRules = pkgs.writers.writeBash "windowRules" ''
			WINDOW_ID=''$(${getField} -d ',' 1 <<< $1)
			CLASS=''$(${getField} -d ',' 3 <<< $1)
			TITLE=''$(${getField} -d ',' 4 <<< $1)

			${lib.concatLines (map (x: x.output "$WINDOW_ID") cfg.windowRules)}
		'';
	in {
		programs.hypr.onEvent.openwindow = [ { cmd = windowRules; args = true; } ];
	};
}
