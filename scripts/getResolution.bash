
RES=$(xrandr --listmonitors | tail -n +2 | getField 4 1 3 | tr ':/x+' '    ')

if [ $# -eq 0 ]; then getField 1 <<< $RES; exit; fi

RES=$(grep $1 <<< $RES)

if [ $# -eq 1 ]; then
	FIND_FIELDS="name xid x y xOffset yOffset"
else
	FIND_FIELDS="${@:2}"
fi

for i in $FIND_FIELDS; do
	case $i in
		name) FIELDS="${FIELDS}1 ";;
		xid) FIELDS="${FIELDS}2 " ;;
		x) FIELDS="${FIELDS}3 " ;;
		y) FIELDS="${FIELDS}5 " ;;
		xOffset) FIELDS="${FIELDS}7 " ;;
		yOffset) FIELDS="${FIELDS}8 " ;;
	esac
done

getField $FIELDS <<< $RES
