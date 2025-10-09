switch:
	sudo nixos-rebuild --flake . switch

switch-traced:
	sudo nixos-rebuild --flake . --show-trace  switch

build:
	nixos-rebuild --flake . build

update:
	nix flake update
	make switch
	# TODO: Commit files using either git or jj dynamically
.PHONY: update

clean:
	nix-collect-garbage
.PHONY: clean
