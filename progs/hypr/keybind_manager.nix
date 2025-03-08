{ lib, config, ... }:
let
	inherit (builtins) map;
	inherit (lib) pipe;
	fpipe = lib.flip pipe;

	global_to_hypr = { mods, key, repeat, description, cmd }: {
		inherit mods key description repeat;
		dispatcher = "execr";
		args = [ cmd ];
	};

	keybinds = config.hypr.keybinds ++ (map global_to_hypr config.global.keybinds);

	modMap = {
		"M" = "SUPER";
		"S" = "SHIFT";
		"C" = "CTRL";
		"A" = "ALT";
	};
	flagIf = b: flag: if b then flag else "";
	process_bind = { mods, key, repeat, description, dispatcher, args }: let
		modMask = pipe mods [ (map (m: modMap.${m})) (lib.concatStringsSep " ") ];
	in
		lib.listToAttrs [
			{
				# d = description (even if empty)
				name = "bind" + "d" + flagIf repeat "e";
				value = lib.concatStringsSep ", " ([ modMask key description dispatcher ] ++ args);
			}
		];

	processed = pipe keybinds [ (map process_bind) lib.zipAttrs ];
in {
	options.hypr.keybinds = with lib; with types; let
		keybind = submodule {
			options = {
				mods = mkOption {
					type = types.strMatching "(M|S|C|A)*";
					apply = fpipe [ lib.stringToCharacters lib.unique ];
				};
				key = mkOption { type = str; };
				dispatcher = mkOption { type = str; };
				args = mkOption {
					type = listOf types.str;
					default = [];
				};
				repeat = mkOption {
					type = bool;
					default = false;
				};
				description = mkOption {
					type = str;
					default = "";
				};
			};
		};
	in
		mkOption {
			default = [ ];
			type = listOf keybind;
		};

	config.wayland.windowManager.hyprland.settings = processed;
}
