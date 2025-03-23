{ ... } @ inputs:
let
	bootstrap = import ./readDir.nix inputs;
in builtins.foldl' (a: b: a // import b inputs) {} (bootstrap.nonDefaultNix ./.)
