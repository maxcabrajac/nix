{ lib, ... }: {
	_module.args.assertNoCollisions = tag: keyFunction: values: let
		inherit (builtins) length groupBy;
		inherit (lib) filterAttrs;
		collisions = values
			|> groupBy keyFunction
			|> filterAttrs (_name: value: length value > 1)
		;
	in {
		assertion = (collisions == {});
		message = "[${tag}] Detected collisions: ${lib.generators.toPretty {} collisions}";
	};
}
