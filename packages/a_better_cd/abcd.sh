#??[runtimeInputs]
#??pkgs = [ "gnused", "coreutils" ]
#??END

ABCD_REGISTRY=/tmp/abcd-registry
touch $ABCD_REGISTRY

escapePath() {
	echo "$1" | sed "s/\//\\\//g"
}

main() {
	case "$1" in
		"add")
			echo $PWD >> $ABCD_REGISTRY
			sort --unique --output=$ABCD_REGISTRY $ABCD_REGISTRY
			;;
		"remove")
			sed -i "\|^$PWD$|d" $ABCD_REGISTRY
			;;
		"find")
			# As $ABCD_REGISTRY is sorted, the longest prefix
			# will be the last one to be found
			while IFS= read -r dir; do
				# check if $dir is a prefix of PWD
				if [ "$PWD" != "${PWD#$dir}" ]; then
					last_dir_that_is_a_prefix="$dir"
				fi
			done < $ABCD_REGISTRY

			if [ "$last_dir_that_is_a_prefix" = "" ]; then
				exit 1
			fi
			echo $last_dir_that_is_a_prefix
			;;
		"list")
			cat $ABCD_REGISTRY
			;;
		"clean")
			rm $ABCD_REGISTRY
			;;
	esac
}

main "$@"
