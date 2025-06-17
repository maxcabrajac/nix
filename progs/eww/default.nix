{ lib, config, ... }: let
	cfg = config.programs.eww;
in {
	options.programs.eww = {
		widgets = lib.mkOption {
			type = with lib.types; let
				widget = submodule {
					args = lib.mkOption {
						type = str;
					};

					def = lib.mkOption {
						type = str;
					};

					# not yet used
					use = lib.mkOption {
						type = listOf str;
					};
				};
			in attrsOf widget;
		};

		window = lib.mkOption {
			type = with lib.types; let
				window = submodule {
					params = lib.mkOption {
						type = attrsOf str;
					};

					widget = lib.mkOption {
						type = str;
					};

					args = lib.mkOption {
						type = str;
					};
				};
			in attrsOf window;
		};

		rawYuck = lib.mkOption {
			type = with lib.types; listOf str;
			default = [];
		};
	};

	config = {
		programs.eww = {
			rawYuck = ["oi"];
			window.bar = {
				params = {
					windowtype = "dock";
					geometry = /*yuck*/''(geometry
						:x "0%"
						:y "0%"
						:width "99%"
						:height "10px"
						:anchor "top center"
					)'';
					exclusive = "true";
				};
			};
		};

		dbg.eww = cfg.rawYuck;
	};
}
