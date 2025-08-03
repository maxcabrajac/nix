switch:
	sudo nixos-rebuild --flake . switch

update:
	nix flake update
	make switch
	git commit flake.lock -m "Upgrade $$(date +%d-%m-%Y)"
.PHONY: update

clean:
	nix-collect-garbage
.PHONY: clean
