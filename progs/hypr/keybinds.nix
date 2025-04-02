{ lib, pkgs, config, ... }: let
	inherit (lib) flip pipe genList imap1;
	cfg = config.programs.hypr;
	bind = mods: key: dispatcher: { inherit mods key dispatcher; };
in {
	programs.hypr.keybinds = lib.flatten [
		(bind "M" "M" "killactive")
		(bind "MS" "Q" "exit")
		(bind "M" "F" "togglefloating")
		(bind "M" "S" "pin")
		{ mods = "M"; key = "Z"; dispatcher = "fullscreen"; args = [ "1" ]; }
		{ mods = "MA"; key = "Z"; dispatcher = "fullscreen"; args = [ "0" ]; }
		(pipe {H = "l"; N = "d"; E = "u"; i = "r"; } [
			lib.attrsToList
			(map ({name, value}: {
				mods = "M";
				key = name;
				dispatcher = "movefocus";
				args = [value];
			}))
		])
		(let
			bttrbind = mods: key: cmd: {
				inherit mods key;
				dispatcher = "execr";
				args = [ "${cfg.bttr} ${cmd}" ];
			};
		in [
			(bttrbind "M" "U" "monitor_workspace cur rel -1")
			(bttrbind "M" "Y" "monitor_workspace cur rel +1")
			(bttrbind "MA" "U" "monitor_workspace cur rel_empty -1")
			(bttrbind "MA" "Y" "monitor_workspace cur rel_empty +1")
			(map (ii: let i = builtins.toString ii; in [
				(bttrbind "M" "${i}" "monitor_workspace cur abs ${i}")
				(bttrbind "MS" "${i}" "move_to_workspace cur abs ${i}")
			]) (genList (x: x + 1) 9))
			(flip imap1 ["T" "D"] (
				ii: let i = toString ii; in key:
					bttrbind "M" key "monitor_workspace all special ${i}"
			))
		])
	];
}
