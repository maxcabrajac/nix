{ config, lib, ... }: let
	t = lib.types;
	cfg = config.monitors;
in {
	options.monitors = lib.mkOption {
		type = t.attrsOf <| t.submodule {
			options = let
				optT = type: lib.mkOption { inherit type; };
				numOpt = optT t.number;
			in {
				x = numOpt;
				y = numOpt;
				w = numOpt;
				h = numOpt;
				refresh = numOpt;

				main = lib.mkOption {
					type = t.bool;
					default = false;
				};
			};
		};

		default = {};
	};

	config = {
		assertions = [
			{
				assertion = let
					cfgList = cfg |> lib.attrValues;
					monitorCount = cfgList |> lib.length;
					mainMonitorCount = cfgList |> lib.filter (x: x.main) |> lib.length;
				in (monitorCount != 0) -> (mainMonitorCount == 1);
				message = "Monitor option must have exactly one main monitor.";
			}
		];

		hmImport = [{
			path = [ "monitors" ];
			value = cfg;
		}];
	};
}
