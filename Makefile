SHELL := /usr/bin/env bash

VERSION ?= 2.1.0
BIN      := symlinkit
EXTRA    := install.sh uninstall.sh
MAN      := man/symlinkit.1
DIST     := dist
TARBALL  := $(DIST)/$(BIN)-$(VERSION).tar.gz

PREFIX   ?= /usr/local
BINDIR   := $(PREFIX)/bin
MANDIR   := $(PREFIX)/share/man/man1

.PHONY: all test tests lint install uninstall release clean

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
	install -m755 $(BIN) $(DESTDIR)$(BINDIR)/$(BIN)
	install -m644 $(MAN) $(DESTDIR)$(MANDIR)/$(BIN).1
	@echo "✅ Installed symlinkit to $(DESTDIR)$(BINDIR)"

uninstall:
	rm -f $(DESTDIR)$(BINDIR)/$(BIN)
	rm -f $(DESTDIR)$(MANDIR)/$(BIN).1
	@echo "✅ Uninstalled symlinkit"

release: clean test lint
	mkdir -p $(DIST)/$(BIN)-$(VERSION)
	cp $(BIN) $(EXTRA) $(MAN) LICENSE README.md $(DIST)/$(BIN)-$(VERSION)/
	tar -czf $(TARBALL) -C $(DIST) $(BIN)-$(VERSION)
	shasum -a 256 $(TARBALL) > $(TARBALL).sha256 || \
	sha256sum $(TARBALL) > $(TARBALL).sha256
	@echo "✅ Release tarball created at $(TARBALL)"

clean:
	rm -rf $(DIST)
	@echo "✅ Cleaned build artifacts"

