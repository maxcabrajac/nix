{ lib, maxLib, ... }@inputs: let
	inherit (lib) pipe;
	modules = pipe (maxLib.nonDefaultNix ./.) [
		(map (p: import p inputs))
	];
in {
	overlay = lib.pipe modules [
		(map (p: final: prev: p.packages prev))
		lib.composeManyExtensions
	];

	homeManagerModule = {...}: {
		imports = pipe modules [
			(builtins.filter (p: p?homeManagerModule))
			(map (p: p.homeManagerModule))
		];
	};
}
