{ config, lib, ... }: with config.lib.niri.actions; let
	modTable = {
		"M" = "Mod";
		"S" = "Shift";
		"C" = "Ctrl";
		"A" = "Alt";
	};

	formatBind = mods: key: lib.concatStringsSep "+" ((map (m: modTable.${m}) mods) ++ [key]);

	intoNiriKeybind = {mods, key, cmd, description, ...}: {
		name = formatBind mods key;
		value = {
			action = spawn cmd;
			hotkey-overlay =
				if isNull description
				then { hidden = true; }
				else { title = description; }
			;
		};
	};
in {
	programs.niri.settings.binds = config.global.finalKeybinds
		|> map intoNiriKeybind
		|> lib.listToAttrs
	;
}
