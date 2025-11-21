{ inputs, lib, ...  }: {
	packages = {
		xdg-desktop-portal-git = { xdg-desktop-portal }: let
			xdp-git = xdg-desktop-portal.overrideAttrs (old: {
				src = inputs.xdp-git;
				doCheck = false;
				patches = let
					refusedPatches = [
						"pkgdatadir"
						"trash-test"
					];

					isRefused = x:
						refusedPatches
						|> lib.any (p: lib.hasInfix p (toString x))
					;
				in
					old.patches |> lib.filter (p: ! isRefused p);
			});
		in
			xdp-git;
	};
}

