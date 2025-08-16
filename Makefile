switch:
	sudo nixos-rebuild --flake . switch

update:
	nix flake update
	make switch
	# TODO: Commit files using either git or jj dynamically
.PHONY: update

clean:
	nix-collect-garbage
.PHONY: clean
