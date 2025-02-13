.PHONY: update

switch:
	nix run .#home-manager -- switch --flake .#main --impure

update:
	nix flake update
	make switch

clean:
	nix-collect-garbage -d
