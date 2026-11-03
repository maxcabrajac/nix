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

		# this is HUGE
		wallpkgs.url = "github:NotAShelf/wallpkgs";

		walker = {
			url = "github:abenz1267/walker";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		cachy-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
		nix-gaming-edge.url = "github:powerofthe69/nix-gaming-edge";
		greenluma = {
			url = "github:AceSLS/SLSsteam";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		nvf = {
			url = "github:NotAShelf/nvf";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		nvim-ayu = { url = "github:Luxed/ayu-vim"; flake = false; };

		sops-nix = {
			url = "github:mic92/sops-nix";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		stylix = {
			url = "github:nix-community/stylix";
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};

	nixConfig = {
		extra-experimental-features = [
			"pipe-operators"
		];

		extra-substituters = [
			"https://cache.lantian.pub/lantian" # cachy-kernel
			"https://nix-cache.tokidoki.dev/tokidoki" # nix-gaming-edge
		];

		extra-trusted-public-keys = [
			"lantian:WVGO7vsRMSEN+h7Lp7kv6SAmrkEXgUGbbXm7jMDjBuQ=" # cachy-kernel
			"tokidoki:MD4VWt3kK8Fmz3jkiGoNRJIW31/QAm7l1Dcgz2Xa4hk=" # nix-gaming-edge
		];
	};

	outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}
