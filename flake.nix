{
	description = "Nix Config";

	inputs = {
		nixpkgs.url = "nixpkgs/nixos-unstable";

		flake-parts.url = "github:hercules-ci/flake-parts";
		import-tree.url = "github:denful/import-tree";
		fp-devshell = {
			url = "github:numtide/devshell";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		systems.url = "github:nix-systems/default-linux";

		home-manager = {
			url = "github:nix-community/home-manager";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		niri-flake = {
			url = "github:epireyn/niri-flake";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		mabar = {
			url = "github:maxcabrajac/mabar";
			inputs.nixpkgs.follows = "nixpkgs";
			inputs.systems.follows = "systems";
			inputs.flake-parts.follows = "flake-parts";
		};

		xdp-git = {
			url = "github:maxcabrajac/xdg-desktop-portal/multiple_cfgs_per_dir_backport";
			flake = false;
		};

		# this is HUGE
		wallpkgs.url = "github:NotAShelf/wallpkgs";

		elephant = {
			url = "github:maxcabrajac/elephant/websearch";
			inputs.nixpkgs.follows = "nixpkgs";
			inputs.systems.follows = "systems";
		};
		walker = {
			url = "github:abenz1267/walker/v2.15.2";
			inputs.elephant.follows = "elephant";
			inputs.nixpkgs.follows = "nixpkgs";
			inputs.systems.follows = "systems";
		};

		cachy-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

		nvf = {
			url = "github:NotAShelf/nvf";
		};

		# max-nvim
		nvim-ayu = { url = "github:Luxed/ayu-vim"; flake = false; };

		greenluma = {
			url = "github:AceSLS/SLSsteam";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		sops-nix = {
			url = "github:mic92/sops-nix";
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};

	nixConfig = {
		extra-experimental-features = [
			"pipe-operators"
		];

		extra-substituters = [
			"https://walker-git.cachix.org"
			"https://attic.xuyh0120.win/lantian" # cachy-kernel
		];

		extra-trusted-public-keys = [
			"walker-git.cachix.org-1:vmC0ocfPWh0S/vRAQGtChuiZBTAe4wiKDeyyXM0/7pM="
			"lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc=" # cachy-kernel
		];
	};

	outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}
