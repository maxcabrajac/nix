#??[runtimeInputs]
#??pkgs = [ "coreutils" ]
#??END

if [ -z "$WALLPAPER_DIR" ]; then
	printf 'Please set $WALLPAPER_DIR\n'
	exit 1
fi

if ! [ -d "$WALLPAPER_DIR" ]; then
	printf '$WALLPAPER_DIR is not a directory\n'
	exit 1
fi

orientation=$1
shift

case $orientation in
	h|v) WALLPAPER_DIR="$WALLPAPER_DIR/$orientation" ;;
	*) printf "Invalid orientation\n"
		exit 1
		;;
esac

if [ ! -d "$WALLPAPER_DIR" ]; then
	printf "$WALLPAPER_DIR is not a directory\n"
fi

printf "$WALLPAPER_DIR/$(ls -1 $WALLPAPER_DIR | shuf -n 1)\n"
