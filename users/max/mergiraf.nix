{
	programs = {
		mergiraf = {
			enable = true;
			enableJujutsuIntegration = true;
		};

		jujutsu.settings.merge-tools.mergiraf.merge-args = [
			"merge" "$base" "$left" "$right"
			"-o" "$output"
			"-l" "$marker_length"
			"-p" "$path"
		];
	};
}
