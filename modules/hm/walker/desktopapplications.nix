{ lib, ... }: {
	hm.base.programs.elephant.provider.desktopapplications.settings = lib.mapAttrs (_: lib.mkDefault) {
		history = false;
		history_when_empty = true;
		wm_integration = true;
		only_search_title = true;
	};
}
