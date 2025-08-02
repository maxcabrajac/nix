{ lib, config, ... }: {
	options = {
		home.shellAbbrs = lib.mkOption {
			type = with lib.types; attrsOf str;
			default = {};
		};
	};

	config = let
		abbrs = config.home.shellAbbrs;
	in lib.fold lib.recursiveUpdate {} <| [{
		programs.fish.shellAbbrs = abbrs;
	}] ++ (
		[
			"bash"
			"zsh"
			"nushell"
		]
		|> map (shell: { programs.${shell}.shellAliases = abbrs; })
	);
}
