{ lib, config, pkgs, ... }: let
	cfg = config.programs.kubectl;
	kubectxAsPlugins = pkgs.runCommandLocal "kubectx-as-plugin" {} /* bash */ ''
		mkdir -p $out/bin
		binPath="${pkgs.kubectx}/bin"
		for b in $binPath/*; do
			# remove kube prefix
			suffix="''${b#$binPath/kube}"
			if [ "$suffix" != "$b" ]; then
				ln -s $b $out/bin/kubectl-$suffix
			fi
		done
	'';
in {
	options.programs.kubectl = {
		enable = lib.mkEnableOption "";
		kubectx = lib.mkEnableOption "" // {
			default = true;
		};
	};

	config = lib.mkIf cfg.enable {
		home.packages = lib.flatten [
			pkgs.kubectl
			(lib.optionals cfg.kubectx [ pkgs.kubectx kubectxAsPlugins ])
		];
	};
}
