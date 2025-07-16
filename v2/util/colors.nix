{ lib, util, ... }: let
	inherit (lib) pipe flip fix imap0 fold;
	fpipe = flip pipe;
in rec {
	# WHY THE FUCK DOESN'T NIX HAVE A MODULO OPERATOR
	mod = a: b: a - (a / b) * b;

	hexToInt = let
		inherit (lib) stringToCharacters reverseList;
		inherit (lib.strings) charToInt;
		zero = charToInt "0";
		nine = charToInt "9";
		A = charToInt "A";
		F = charToInt "F";
		pow = fix (self: base: power:
			if power == 0
			then 1
			else if power == 1
				then base
				else let
						base2 = base * base;
						isOdd = mod power 2;
						halfPower = (power - isOdd) / 2;
					in
						(self base2 halfPower) * (if isOdd == 1 then base else 1)
		);
	in fpipe [
		stringToCharacters
		(map (ch: let
				c = charToInt ch;
			in
				if (zero <= c) && (c <= nine)
				then c - zero
				else if (A <= c) && (c <= F)
					then 10 + c - A
					else throw "Invalid hex ${ch}"
		))
		reverseList
		(imap0 (index: value: value * (pow 16 index)))
		(fold (a: b: a + b) 0)
	];

	intToHex = fix (self: n: let
		rem = mod n 16;
		next = (n - rem) / 16;
		letter = [ "0" "1" "2" "3" "4" "5" "6" "7" "8" "9" "A" "B" "C" "D" "E" "F" ];
	in
		if n == 0 then "" else "${self next}${builtins.elemAt letter rem}"
	);

	types.color = let
		parseHexColor = str: let
			hex = lib.removePrefix "#" str;
		in
			{
				r = hexToInt (builtins.substring 0 2 hex);
				g = hexToInt (builtins.substring 2 2 hex);
				b = hexToInt (builtins.substring 4 2 hex);
			};
	in with lib.types; coercedTo (strMatching "#[0-9A-F]{6}") parseHexColor (submodule ({ config, ... }: {
			options = {
				# inputs
				r = lib.mkOption {
					type = int;
				};
				g = lib.mkOption {
					type = int;
				};
				b = lib.mkOption {
					type = int;
				};

				# outputs
				r-hex = lib.mkOption {
					type = str;
				};
				g-hex = lib.mkOption {
					type = str;
				};
				b-hex = lib.mkOption {
					type = str;
				};
				hex = lib.mkOption {
					type = str;
				};
				hhex = lib.mkOption {
					type = str;
				};
				r-float = lib.mkOption {
					type = float;
				};
				g-float = lib.mkOption {
					type = float;
				};
				b-float = lib.mkOption {
					type = float;
				};
			};

			config = let
				intToColorPart = i: util.leftPad "0" 2 (intToHex i);
			in with config; {
				r-hex = intToColorPart r;
				g-hex = intToColorPart g;
				b-hex = intToColorPart b;
				hex = "${r-hex}${g-hex}${b-hex}";
				hhex = "#${hex}";
				r-float = r / 255.0;
				b-float = b / 255.0;
				g-float = g / 255.0;
			};
		}));
}
