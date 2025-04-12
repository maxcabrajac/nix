{ lib, ... } @ inputs:
let
	bootstrap = import ./readDir.nix inputs;
in lib.fix (self: builtins.foldl' (a: b: a // import b (inputs // { maxLib = self; })) {} (bootstrap.nonDefaultNix ./.))
