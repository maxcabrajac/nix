{ lib, ... }: let
	inherit (lib)
		mkOption
	;
	inherit (builtins)
		elemAt
		filter
		any
	;
	inherit (lib.types)
		submodule
		listOf
		enum
		str
		bool
		coercedTo
	;
	keybindModule = submodule {
		options = {
			mods = mkOption {
				type = listOf (enum ["M" "S" "C" "A"]);
				apply = mods:
					mods
					|> lib.unique
					|> lib.naturalSort
				;
			};
			key = mkOption { type = str; };
			repeat = mkOption {
				type = bool;
				default = false;
			};
		};
	};

	# * = repeat
	# [*](M|S|C|A)-<key>
	# this parser also accepts M*S-key, but idc
	parseKeybindStr = keybindStr: let
		parts = lib.strings.splitString "-" keybindStr;
		modchars = elemAt parts 0 |> lib.stringToCharacters;
	in {
      mods = modchars |> filter (x: x != "*");
      key = elemAt parts 1;
      repeat = modchars |> any (x: x == "*");
	};
in {
	types.keybind = keybindModule
		|> coercedTo str parseKeybindStr
	;
}
