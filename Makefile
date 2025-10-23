switch:
	nh os switch . -a

build:
	nh os build . -Q

build-traced:
	nh os build . -Q --show-trace

update:
	nix flake update
	make switch
.PHONY: update

clean:
.PHONY: clean
