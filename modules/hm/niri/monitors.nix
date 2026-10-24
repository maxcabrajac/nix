{ lib, ... }: {
	hm.base = { osConfig, ... }: {
		programs.niri.settings.outputs = osConfig.monitors or {} |> lib.mapAttrs (_: m: {
			mode = {
				height = m.h;
				width = m.w;
				refresh = m.refresh;
			};
			position = {
				inherit (m) x y;
			};
		});
	};
}
