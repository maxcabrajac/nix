{ lib, ... }: {
	hm.base = { config, pkgs, ... }: let
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
		# NOTE: "dendritic guy" advises against using mkEnableOption :shrug:
		options.programs.kubectl = {
			enable = lib.mkEnableOption "";
		};

		config = lib.mkIf cfg.enable {
			home.packages = [
				pkgs.kubectl
				pkgs.kubectx
				kubectxAsPlugins
			];
		};
	};
}
