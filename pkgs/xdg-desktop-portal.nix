{ inputs, lib, ...  }: {
	packages = {
		xdg-desktop-portal = { stdenv }: let
			base = inputs.nixpkgs.legacyPackages.${stdenv.hostPlatform.system}.xdg-desktop-portal;
			xdp-git = base.overrideAttrs (old: {
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

			prLink = "https://github.com/flatpak/xdg-desktop-portal/pull/1867";
			alarmMessage = "A new xdg-portal release (${base.version}) hit nixpkgs. Time to check if ${prLink} is upstreamed.";
		in
			lib.warnIf (base.version != "1.20.3") alarmMessage xdp-git;
	};
}

