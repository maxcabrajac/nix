{ lib, ... }: {
	packages.fzf-funnel = { writers, fzf, gnugrep, coreutils }: writers.writeBashBin "fzf-funnel" ''
		PATH=${lib.makeBinPath [ fzf gnugrep coreutils ]}
		${builtins.readFile ./main.sh}
	'';
}

