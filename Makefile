SHELL := /usr/bin/env bash

VERSION := $(shell awk -F= '/^VERSION=/{gsub(/"/,"");print $$2}' scripts/symlinkit)

BIN      := scripts/symlinkit
EXTRA    := scripts/install.sh scripts/uninstall.sh
MAN      := man/symlinkit.1
DIST     := dist
TARBALL  := $(DIST)/symlinkit-$(VERSION).tar.gz

PREFIX   ?= /usr/local
BINDIR   := $(PREFIX)/bin
MANDIR   := $(PREFIX)/share/man/man1

.PHONY: all test tests lint install uninstall release clean bump

all: test lint
	@echo "🎉 Build successful — all tests and lint passed. Ready to ship!"

test:
	bats tests
	@echo "✅ All bats tests passed"

tests: test

lint:
	shellcheck $(BIN) $(EXTRA)
	@echo "✅ All scripts passed shellcheck"

install:
	mkdir -p $(DESTDIR)$(BINDIR) $(DESTDIR)$(MANDIR)
	install -m755 $(BIN) $(DESTDIR)$(BINDIR)/$(notdir $(BIN))
	install -m644 $(MAN) $(DESTDIR)$(MANDIR)/$(notdir $(MAN))
	@echo "✅ Installed symlinkit to $(DESTDIR)$(BINDIR)"

uninstall:
	rm -f $(DESTDIR)$(BINDIR)/$(notdir $(BIN))
	rm -f $(DESTDIR)$(MANDIR)/$(notdir $(MAN))
	@echo "✅ Uninstalled symlinkit"

release: clean test lint
	mkdir -p $(DIST)/$(notdir $(BIN))-$(VERSION)
	cp $(BIN) $(EXTRA) $(MAN) LICENSE README.md $(DIST)/$(notdir $(BIN))-$(VERSION)/
	tar -czf $(TARBALL) -C $(DIST) $(notdir $(BIN))-$(VERSION)
	shasum -a 256 $(TARBALL) > $(TARBALL).sha256 || \
	sha256sum $(TARBALL) > $(TARBALL).sha256
	@echo "✅ Release tarball created at $(TARBALL)"

clean:
	rm -rf $(DIST)
	@echo "✅ Cleaned build artifacts"

bump:
	@if [ -z "$(word 2,$(MAKECMDGOALS))" ]; then \
		echo "❌ Usage: make bump X.Y.Z"; \
		exit 1; \
	fi
	@NEW=$(word 2,$(MAKECMDGOALS)); \
	gsed -i 's/^VERSION=.*/VERSION="'$$NEW'"/' scripts/symlinkit 2>/dev/null || \
	sed -i '' -e 's/^VERSION=.*/VERSION="'$$NEW'"/' scripts/symlinkit; \
	if [ -f man/symlinkit.1 ]; then \
	  gsed -i "1s/[0-9]\+\.[0-9]\+\.[0-9]\+/"$$NEW"/" man/symlinkit.1 2>/dev/null || \
	  sed -i '' -e "1s/[0-9]\+\.[0-9]\+\.[0-9]\+/"$$NEW"/" man/symlinkit.1; \
	fi; \
	git add scripts/symlinkit man/symlinkit.1 || true; \
	git commit -m "chore(release): bump to v"$$NEW; \
	git tag v$$NEW; \
	echo "✅ Bumped to v$$NEW and created tag. Push with: git push origin main --follow-tags"

