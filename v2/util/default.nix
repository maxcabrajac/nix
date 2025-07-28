{ lib, ... } @ inputs:
let
	bootstrap = import ./readDir.nix inputs;
in lib.fix (self:
	builtins.foldl'
		(a: b:
			import b (inputs // { util = self; })
			|> lib.recursiveUpdate a
		)
		{}
		(bootstrap.nonDefaultNix ./.)
	)
