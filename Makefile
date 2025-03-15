USER = $(shell whoami)
HOST = $(shell uname -n)
IS_HM_INSTALLED = $(shell which home-manager 2>&1 > /dev/null; echo $$?)
ifeq ($(IS_HM_INSTALLED),0)
	HM_CMD = home-manager
endif
HM_CMD ?= nix run .\#home-manager --
HM = USER=$(USER) HOST=$(HOST) $(HM_CMD)

switch:
	$(HM) switch -b bak --flake .#main --impure
.PHONY: switch

switch-traced:
	$(HM) switch -b bak --flake .#main --impure --show-trace
.PHONY: switch-traced

update:
	nix flake update
	make switch
	git commit flake.lock -m "Upgrade $$(date +%d-%m-%Y)"
.PHONY: update

clean:
	nix-collect-garbage
.PHONY: clean
