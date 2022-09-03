.RECIPEPREFIX = >
ROOTDIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

GPXDIR := $(ROOTDIR)/outdoors-data/

all: dist

$(ROOTDIR)/public/tiles:
> nix-shell --command 'gpx-to-pbf $(GPXDIR) $@'

$(ROOTDIR)/public/_pagefind:
> nix-shell --command 'gen-search-index $(GPXDIR) $@'

dist: $(ROOTDIR)/public/tiles $(ROOTDIR)/public/_pagefind
> yarn run build-only
> cp -r public/** dist/
.PHONY: dist
