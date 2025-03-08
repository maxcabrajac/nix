{ ... }: with builtins; rec {
	deepMerge = zipAttrsWith
		(_: values:
			if all isAttrs values then
				deepMerge values
			else if all isList values then
				concatLists values
			else
				# If values are not mergeable, use last
				elemAt values (length values - 1)
		);

}
