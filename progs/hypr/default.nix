{ pkgs, lib, config, ... }:
with lib;
let
	cfg = config.programs.hypr;
	getWallpaper = config.programs.getWallpaper.configured_pkg;
	scripts = pkgs.scriptDir { inherit pkgs; configured = { inherit getWallpaper; }; } ./scripts;
in {

	imports = [
		./idlelock.nix
		./keybind_manager.nix
		./no_gaps_on_maximize.nix
		./wrapper.nix
		./event_handler.nix
	];

	options = {
		programs.hypr.enable = mkEnableOption "hypr";
	};

	config = mkIf cfg.enable {
		home.packages = with pkgs; [
			kitty
			dunst
		] ++ lib.attrValues scripts;

		programs.hypr.keybinds = let
			bind = mods: key: dispatcher: { inherit mods key dispatcher; };
		in
			lib.flatten [
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
						args = [ "${lib.getExe scripts.bttr} ${cmd}" ];
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

		wayland.windowManager.hyprland = {
			enable = true;
			plugins = pkgs.hypr_plugs;
			systemd.enableXdgAutostart = true;

			settings = {
				debug = {
					disable_logs = true;
				};

				exec-once = [
					"dunst"
					"${lib.getExe scripts.bttr} monitor_workspace all abs 1"
					"${lib.getExe scripts.hyprSetWallpaper}"
				];

				env = [
					"DMENU,bemenu"
				];

				general = {
					layout = "dwindle";
					allow_tearing = false;
					no_focus_fallback = true;
				};

				dwindle = {
					force_split = 2; # split to the right
					pseudotile = false;
				};

				misc = {
					disable_hyprland_logo = true;

					# TODO: do something to generalize swallowing
					enable_swallow = true;
					swallow_regex = ".*kitty.*";
					swallow_exception_regex = ".*(wev|cargo run).*";

					force_default_wallpaper = 0;
					initial_workspace_tracking = let
						disable = 0;
						only_first_window = 1;
						all_children = 2;
					in
						all_children;

					new_window_takes_over_fullscreen = let
						behind = 0;
						takes_over = 1;
						unfullscreen = 2;
					in
						unfullscreen;
				};
			};

			extraConfig = ''
			$mainMod = SUPER

			env = PATH,$HOME/.bin/hyprland/:$PATH

			exec-once = eventHandler

			# Execute your favorite apps at launch
			exec-once = $XDG_CONFIG_HOME/eww/run.sh &
			exec-once = youtube-music & sleep 1; telegram-desktop &

			# Source a file (multi-file configs)
			$hypr_dir = $XDG_CONFIG_HOME/hypr
			source = $hypr_dir/hardware.conf
			source = $hypr_dir/styling.conf

			# Some default env vars.
			# env = XCURSOR_SIZE,24
			env = QT_QPA_PLATFORMTHEME,qt6ct # change to qt6ct if you have that

			# Example windowrule v1
			# windowrule = float, ^(kitty)$
			# Example windowrule v2
			# windowrulev2 = float,class:^(kitty)$,title:^(kitty)$
			# See https://wiki.hyprland.org/Configuring/Window-Rules/ for more
			# windowrulev2 = nomaximizerequest, class:.* # You'll probably like this.
			windowrulev2 = tile, class:(Vivaldi-stable)
			windowrulev2 = maximize, class:(org.telegram.desktop),title:(Media viewer)


			# See https://wiki.hyprland.org/Configuring/Keywords/ for more

			# Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
			bind = $mainMod, Return, exec, kitty

			# Media
			bind = ,XF86AudioNext, execr, mediaManager next
			bind = ,XF86AudioPrev, execr, mediaManager prev
			bind = ,XF86AudioPlay, execr, mediaManager playpause
			bind = $mainMod,XF86AudioRaiseVolume, execr, mediaManager next
			bind = ,XF86AudioMute, execr, soundCtrl mute
			binde = ,XF86AudioRaiseVolume, execr, soundCtrl inc 5
			binde = ,XF86AudioLowerVolume, execr, soundCtrl dec 5
			bind = $mainMod,XF86AudioMute, execr, mediaManager playpause
			bind = $mainMod,XF86AudioLowerVolume, execr, mediaManager prev
			bind = $mainMod,XF86AudioRaiseVolume, execr, mediaManager next

			# ScrBright
			binde = ,XF86MonBrightnessUp, execr, scrBright inc 5%
			binde = ,XF86MonBrightnessDown, execr, scrBright dec 5%

			# Scroll through existing workspaces with mainMod + scroll
			bind = $mainMod, mouse_down, workspace, e+1
			bind = $mainMod, mouse_up, workspace, e-1

			# Move/resize windows with mainMod + LMB/RMB and dragging
			bindm = $mainMod, mouse:272, movewindow
			bindm = $mainMod, mouse:273, resizewindow

			# PrintScr
			bind = $mainMod, F4, exec, printScr cbpart
			bind = $mainMod, F3, exec, printScr cbfull
			bind = $mainMod ALT, F4, exec, printScr part
			bind = $mainMod ALT, F3, exec, printScr full
			'';
		};

		services.hyprpaper = {
			enable = true;
			settings.ipc = "on";
		};

		programs.hypr.onEvent.monitoradded = [
			"${lib.getExe scripts.hyprSetWallpaper}"
		];
	};

}
