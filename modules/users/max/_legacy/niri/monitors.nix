{ config, lib, ... }: {
	programs.niri.settings.outputs = config.host.monitors |> lib.mapAttrs (_: m: {
		mode = {
			height = m.h;
			width = m.w;
			refresh = m.refresh;
		};
		position = {
			inherit (m) x y;
		};
	});
}
