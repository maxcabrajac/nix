{ lib, config, ... }: {
	options = {
		hmImport = lib.mkOption {
			type = with lib.types; listOf <| submodule ({ config, ... }: {
				options = {
					path = lib.mkOption {
						type = listOf str;
					};

					value = lib.mkOption {
						type = raw;
					};

					module = lib.mkOption {
						type = raw;
						readOnly = true;
					};
				};

				config = {
					module = let
						onPath = lib.setAttrByPath (["host"] ++ config.path);
					in {
						options = onPath <| lib.mkOption {
							type = raw;
							readOnly = true;
						};

						config = onPath <| config.value;
					};
				};
			});
			default = [];
		};
	};

	config = {
		home-manager.sharedModules = config.hmImport |> map (x: x.module);
	};
}
