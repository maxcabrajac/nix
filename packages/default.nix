{ lib, maxLib, ... }@inputs: let
	inherit (lib) pipe;
	modules = pipe (maxLib.nonDefaultNix ./.) [
		(map (p: import p inputs))
	];
in rec {
	packages = pkgs: lib.pipe modules [
		(map (p: p.packages { inherit pkgs; }))
		lib.mergeAttrsList
		(lib.traceVal)
	];

	overlay = final: prev: packages final;

	homeManagerModule = {...}: {
		imports = pipe modules [
			(builtins.filter (p: p?homeManagerModule))
			(map (p: p.homeManagerModule))
		];
	};
}
