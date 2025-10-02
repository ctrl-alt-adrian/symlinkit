SHELL := /usr/bin/env bash

VERSION ?= 2.0.2
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
	@if [ -z "$(VERSION)" ]; then \
		echo "❌ VERSION is required. Usage: make bump VERSION=2.0.2"; \
		exit 1; \
	fi
	sed -i.bak -E "s/^(VERSION \?\= ).*/\1$(VERSION)/" Makefile
	rm -f Makefile.bak
	git add Makefile
	git commit -m "Release v$(VERSION)"
	git tag v$(VERSION)
	@echo "✅ Bumped version to $(VERSION) and created tag v$(VERSION)"
	@echo "👉 Now run: git push origin main --tags"

