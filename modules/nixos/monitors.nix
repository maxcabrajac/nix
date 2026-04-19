{ config, lib, ... }: let
	t = lib.types;
	cfg = config.monitors;
in {
	options = {
		monitors = lib.mkOption {
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

		mainMonitor = lib.mkOption {
			type = t.str;
			readOnly = true;
		};
	};

	config = let
		cfgList = cfg |> lib.attrValues;
		monitorCount = cfgList |> lib.length;
	in
		lib.mkMerge [
			(lib.mkIf (monitorCount != 0) {
				assertions = [
					{
						assertion = let
							mainMonitorCount = cfgList |> lib.filter (x: x.main) |> lib.length;
						in mainMonitorCount == 1;
						message = "Monitor option must have exactly one main monitor.";
					}
				];

				mainMonitor = cfg
					|> lib.filterAttrs (_: m: m.main)
					|> lib.attrNames
					|> lib.head
				;
			})
			{
				hmImport = [
					{
						path = [ "monitors" ];
						value = cfg;
					}
					{
						path = [ "mainMonitor" ];
						value = config.mainMonitor;
					}
				];
			}
		];
}
