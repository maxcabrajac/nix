.PHONY: update

CORES = $(shell nproc --all)

switch:
	nix run .#home-manager -- switch --flake .#main --impure --cores $(CORES)

update:
	nix flake update
	make switch

clean:
	nix-collect-garbage -d
