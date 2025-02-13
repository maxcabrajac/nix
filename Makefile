.PHONY: update

update:
	nix run .#home-manager -- switch --flake .#main --impure

clean:
	nix-collect-garbage -d
