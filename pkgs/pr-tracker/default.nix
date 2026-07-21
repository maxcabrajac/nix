{ lib, ... }: {
	packages.pr-tracker = { writers, gh, jq, moreutils, util-linux, coreutils }: writers.writeBashBin "pr-tracker" ''
		PATH=${lib.makeBinPath [ gh jq moreutils util-linux coreutils ]}
		${builtins.readFile ./main.sh}
	'';
}

