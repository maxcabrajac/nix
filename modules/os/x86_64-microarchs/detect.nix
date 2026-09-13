{ lib, ... }: {
	os.base = { config, pkgs, ... }: {
		options.hardware.cpu.x86.microarch = lib.mkOption {
			type = lib.types.enum <| lib.attrNames lib.systems.architectures.features;
			default = let
				failurePrefix = "Configuration depends on x86 microarch but autodetection failed:";
				failIf = cond: msg: value: if cond then lib.warn "${failurePrefix} ${msg}" "x86-64" else value;

				cpus = config.hardware.facter.report.hardware.cpu;
				cpuCount = lib.length cpus;
				cpu = lib.head cpus;

				# Somewhere along the facter chain, some features are ommited cause they are reduntant with other features.
				# We add them back here.
				featureSupersets = {
					ssse3 = [ "sse3" ];
				};
				cpuFeatures = cpu.features
					|> lib.map (feat: [feat] ++ (featureSupersets.${feat} or []))
					|> lib.flatten
				;

				cpuImplements = microarch:
					lib.systems.architectures.features.${microarch}
					|> lib.all (feat: lib.elem feat cpuFeatures)
				;

				testOrder = [
					"x86-64-v4"
					"x86-64-v3"
					"x86-64-v2"
					"x86-64"
				];
			in
				failIf (pkgs.stdenv.hostPlatform.isx86_64 == false) "hostPlatform is not x86_64"
				<| failIf (config.hardware.facter.enable == false) "facter report is required"
				<| failIf (cpuCount != 1) "facter report contains ${cpuCount} (!= 1) cpus"
				<| lib.lists.findFirst cpuImplements "UNREACHABLE DEFAULT" testOrder
			;
		};
	};
}
