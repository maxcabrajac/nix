#??[runtimeInputs]
#??pkgs = ["gawk"]
#??END

DELIM=' '

if [ "$1" = "-d" ]; then
	DELIM="$2"
	shift 2
fi

FIELDS=""
for i in $@; do
	FIELDS="$FIELDS\$$i,"
done

if [ "$FIELDS" = "" ]; then
	echo "ERROR: no fields selected"
	exit 1
fi

awk -F "$DELIM" "NF{print ${FIELDS::-1}}"
