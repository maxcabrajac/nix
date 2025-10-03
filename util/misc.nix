{ lib, ... }: with builtins; rec {
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

	prettyString = lib.generators.toPretty {};

	checkCollisions = tag: f: x: let
		inherit (builtins) length groupBy;
		inherit (lib) pipe filterAttrs attrNames throwIf;
		collisions = pipe x [
				(groupBy f)
				(filterAttrs (name: value: length value > 1))
			];
		collision_count = length (attrNames collisions);
	in
		throwIf (collision_count > 0) "[${tag}] Collisions were detected on: ${prettyString collisions}" x;

	leftPad = char: len: str: let
		curLen = builtins.stringLength str;
		padLen = lib.max 0 (len - curLen);
		padChars = lib.genList (_: char) padLen;
		pad = lib.concatStrings padChars;
	in
		pad + str;

	safeGetAttrFromPath = path: default: attr:
		if lib.hasAttrByPath path attr
		then lib.getAttrFromPath path attr
		else default
	;

	types = {
		# simpler version of coercedTo
      into = finalT: func: initialT: lib.types.coercedTo initialT func finalT;

		apply = f: t: t // {
			merge = loc: values: f (t.merge loc values);
		};
	};

	assertions.noCollisions = tag: keyFunction: values: let
		inherit (builtins) length groupBy;
		inherit (lib) filterAttrs;
		collisions = values
			|> groupBy keyFunction
			|> filterAttrs (name: value: length value > 1)
		;
	in {
		assertion = (collisions == {});
		message = "[${tag}] Detected collisions: ${prettyString collisions}";
	};
}
