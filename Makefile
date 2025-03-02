.PHONY: update

CORES = $(shell nproc --all)
USER = $(shell whoami)
HOST = $(shell uname -n)

switch:
	USER=$(USER) HOST=$(HOST) nix run .#home-manager -- switch -b bak --flake .#main --impure --cores $(CORES)

update:
	nix flake update
	make switch
	git commit flake.lock -m Upgrade


clean:
	nix-collect-garbage
