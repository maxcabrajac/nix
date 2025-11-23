{ lib, util, config, pkgs, ... }: with lib; let
	inherit (util.types) into;
in {
	options.global = let
		keybind = { config, ... }: {
			options = with types; {
				combo = mkOption {
					type = str;
				};

				finalCombo = mkOption {
					type = str;
				};

				mods = mkOption {
					type = listOf (enum ["M" "S" "C" "A"]);
				};

				key = mkOption {
					type = str;
				};

				sh = mkOption {
					type = nullOr str;
					default = null;
				};

				pkg = mkOption {
					type = package;
					default = pkgs.writeShellScriptBin "${config.finalCombo}-keybind-script" config.sh;
				};

				cmd = mkOption {
					type =
						str
						|> into (listOf str) (splitString " ")
					;
					default = getExe config.pkg;
				};

				repeat = mkOption {
					type = bool;
					default = false;
				};

				description = mkOption {
					type = nullOr str;
					default = null;
				};
			};

			config = let
				parts = splitString "-" config.combo;
				assertF = f: msg: x: lib.throwIfNot (f x) msg x;
				partCount = length parts |> assertF (x: x <= 2) "Invalid keybind format ${config.combo}";
			in {
				mods = (if partCount == 2 then elemAt parts 0 else "")
					|> stringToCharacters
					|> naturalSort
					|> unique
				;
				key = elemAt parts (partCount - 1);

				finalCombo = [
					(concatStrings config.mods)
					config.key
				] |> filter (x: x != "") |> concatStringsSep "-";
			};
		};
	in with types; {
		keybinds = mkOption {
			type = attrsOf attrs;
		};

		finalKeybinds = mkOption {
			readOnly = true;
			type = listOf <| submodule keybind;
		};
	};

	config = {
		assertions = [
			(util.assertions.noCollisions "global.keybinds" ({ finalCombo, ... }: finalCombo) config.global.finalKeybinds)
		];

		global.finalKeybinds = config.global.keybinds
			|> mapAttrs (combo: bind: bind // { inherit combo; })
			|> attrValues
		;
	};
}
