{ config, ... }: {
	hm.aws = {
		imports = [
			config.hm.aws_profile
		];
		config.programs.awscli.enable = true;
	};
}
