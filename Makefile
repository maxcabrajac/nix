NIX_OUT=/tmp/nix-build-output
HOME_CONFIG:=.\#homeConfigurations."${USER}@${shell hostname}".config

search-option:
	nix run '$(HOME_CONFIG).programs.nix-search.opt.package'

hm-news:
	nix run '$(HOME_CONFIG).news.view'

switch:
	nh os switch . -a

build:
	nh os build -o $(NIX_OUT) .

build-traced:
	nh os build -o $(NIX_OUT) . --show-trace

hm-switch:
	nh home switch . -a

update:
	nix flake update
	make switch
.PHONY: update

clean:
.PHONY: clean
