.PHONY: update

update:
	nix run .#home-manager -- switch --flake .#main

clean:
	nix-collect-garbage -d
