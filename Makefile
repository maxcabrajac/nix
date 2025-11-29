NIX_OUT=/tmp/nix-build-output

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
