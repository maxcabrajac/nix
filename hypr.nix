{ lib, pkgs, config, ... }: let
	# Wrapper has to be installed alongside the main package, otherwise xdg-portal-hyprland's cachix is invalidated
	wrapper = with pkgs; writeShellApplication {
		name = "hypr";
		runtimeInputs = [ (config.lib.nixGL.wrap hyprland) ];
		text = "Hyprland";
	};
in {
	home = {
		packages = with pkgs; [
			wrapper
			eww
		];
	};

	wayland.windowManager.hyprland = {
		enable = true;
		plugins = pkgs.hypr_plugs;

		extraConfig = ''
$mainMod = SUPER
$terminal = kitty

env = PATH,$HOME/.bin/hyprland/:$PATH

env = XDG_SESSION_DESKTOP,Hyprland

debug {
	disable_logs = false
}

exec-once = eventHandler

# Execute your favorite apps at launch
exec-once = dunst &
exec-once = $XDG_CONFIG_HOME/eww/run.sh & setWallpaper &
exec-once = xss-lock -l lock &
exec-once = youtube-music & sleep 1; telegram-desktop &

# Source a file (multi-file configs)
$hypr_dir = $XDG_CONFIG_HOME/hypr
source = $hypr_dir/hardware.conf
source = $hypr_dir/styling.conf

# Plugins
exec-once = hyprpm reload
source = $hypr_dir/hyprgrass.conf

env = DMENU,bemenu

# Some default env vars.
env = XCURSOR_SIZE,24
env = QT_QPA_PLATFORMTHEME,qt5ct # change to qt6ct if you have that

general {
	layout = dwindle
	allow_tearing = false
	no_focus_fallback = true
}

input {
	mouse_refocus = false
}

dwindle {
	force_split = 2
	pseudotile = yes
}

workspace = w[tv1], gapsout:0, gapsin:0
workspace = f[1], gapsout:0, gapsin:0
windowrulev2 = bordersize 0, floating:0, onworkspace:w[tv1]
windowrulev2 = rounding 0, floating:0, onworkspace:w[tv1]
windowrulev2 = bordersize 0, floating:0, onworkspace:f[1]
windowrulev2 = rounding 0, floating:0, onworkspace:f[1]

misc {
	disable_hyprland_logo = true
	enable_swallow = true
	swallow_regex = (kitty)
	swallow_exception_regex = .*(wev|xev|cargo run).*
	force_default_wallpaper = 0 # Set to 0 to disable the anime mascot wallpapers

	new_window_takes_over_fullscreen = 2
}

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
bind = $mainMod, Return, exec, $terminal
bind = $mainMod, M, killactive
bind = $mainMod SHIFT, Q, exit
bind = $mainMod, F, togglefloating
bind = $mainMod, space, exec, menu_run
bind = $mainMod, O, exec, menu_search
bind = $mainMod, P, pseudo
bind = $mainMod, S, pin
bind = $mainMod, J, togglesplit

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

# Move focus with mainMod + arrow keys
bind = $mainMod, H, movefocus, l
bind = $mainMod, I, movefocus, r
bind = $mainMod, E, movefocus, u
bind = $mainMod, N, movefocus, d

bind = $mainMod, Z, fullscreen, 1
bind = $mainMod ALT, Z, fullscreen, 0

bind = $mainMod, U, execr, bttr monitor_workspace cur rel -1
bind = $mainMod, Y, execr, bttr monitor_workspace cur rel +1
bind = $mainMod ALT, U, execr, bttr monitor_workspace cur rel_empty -1
bind = $mainMod ALT, Y, execr, bttr monitor_workspace cur rel_empty +1

# Move active window to a workspace with mainMod + SHIFT + [0-9]
bind = $mainMod, 1, execr, bttr monitor_workspace cur abs 1
bind = $mainMod, 2, execr, bttr monitor_workspace cur abs 2
bind = $mainMod, 3, execr, bttr monitor_workspace cur abs 3
bind = $mainMod, 4, execr, bttr monitor_workspace cur abs 4
bind = $mainMod, 5, execr, bttr monitor_workspace cur abs 5
bind = $mainMod, 6, execr, bttr monitor_workspace cur abs 6
bind = $mainMod, 7, execr, bttr monitor_workspace cur abs 7
bind = $mainMod, 8, execr, bttr monitor_workspace cur abs 8
bind = $mainMod, 9, execr, bttr monitor_workspace cur abs 9
bind = $mainMod, 0, execr, bttr monitor_workspace cur abs 10

# Move active window to a workspace with mainMod + SHIFT + [0-9]
bind = $mainMod SHIFT, 1, execr, bttr move_to_workspace cur cur abs 1
bind = $mainMod SHIFT, 2, execr, bttr move_to_workspace cur cur abs 2
bind = $mainMod SHIFT, 3, execr, bttr move_to_workspace cur cur abs 3
bind = $mainMod SHIFT, 4, execr, bttr move_to_workspace cur cur abs 4
bind = $mainMod SHIFT, 5, execr, bttr move_to_workspace cur cur abs 5
bind = $mainMod SHIFT, 6, execr, bttr move_to_workspace cur cur abs 6
bind = $mainMod SHIFT, 7, execr, bttr move_to_workspace cur cur abs 7
bind = $mainMod SHIFT, 8, execr, bttr move_to_workspace cur cur abs 8
bind = $mainMod SHIFT, 9, execr, bttr move_to_workspace cur cur abs 9
bind = $mainMod SHIFT, 0, execr, bttr move_to_workspace cur cur abs 10

# Special workspace
bind = $mainMod, T, execr, bttr monitor_workspace all special 1
bind = $mainMod, D, execr, bttr monitor_workspace all special 2

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
}
