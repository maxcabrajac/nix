#??[runtimeInputs]
#??configured = ["getWallpaper"]
#??pkgs = ["jq", "bc", "hyprland", "hyprpaper"]

ms="$(hyprctl monitors -j)"

m_count=$(printf "$ms" | jq length)

i=0

while [ "$i" -lt "$m_count" ]; do
	is_h=$(printf "$ms" | jq -r ".[$i] | \"((\(.width) > \(.height)) + \(.transform)) % 2\"" | bc)

	if [ $is_h -eq 1 ]; then
		image=$(getWallpaper h)
	else
		image=$(getWallpaper v)
	fi

	monitor=$(printf "$ms" | jq -r ".[$i].name")

	hyprctl hyprpaper reload "$monitor,$image" > /dev/null

	i=$(($i + 1))
done
