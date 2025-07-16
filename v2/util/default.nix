{ lib, ... } @ inputs:
let
	bootstrap = import ./readDir.nix inputs;
in lib.fix (self: builtins.foldl' (a: b: a // import b (inputs // { util = self; })) {} (bootstrap.nonDefaultNix ./.))
