{ lib, ... }: {
	hm.fish-auto-ls.config.programs.fish.shellInit = /* fish */ ''
		set AUTOLS_DISABLE false
		function autols --on-variable PWD
			if ! ''$AUTOLS_DISABLE
				ls
			end
		end
	'';
	hm.fish-keep-dir.config.programs.fish = let
		file = "/tmp/fish_kept_dir";
	in {
		shellAliases.cdd = /* fish */ ''test -f "${file}" && builtin cd (cat ${file})'';
		interactiveShellInit = /* fish */ ''
			function keep_dir --on-event fish_prompt
				pwd > ${file}
			end
			cdd
		'';
	};
	hm.base = { config, pkgs, ... }: {
		xdg.configFile = lib.mkIf config.programs.fish.enable {
			"fish/completions/nix.fish".source = "${pkgs.nix}/share/fish/vendor_completions.d/nix.fish";
		};
	};
}
