NIX_OUT=/tmp/nix-build-output

diff:
	dix $$(nix-store --query --deriver $$(realpath /run/current-system)) $$(nix eval .#nixosConfigurations.nixos.config.system.build.toplevel.drvPath --raw)

test:
	nh os test .

switch:
	nh os switch . -a

build:
	nh os build -o $(NIX_OUT) .

build-traced:
	nh os build -o $(NIX_OUT) . --show-trace

hm-switch:
	nh home switch . -a

update:
	nix flake update
	make switch
.PHONY: update

clean:
.PHONY: clean
