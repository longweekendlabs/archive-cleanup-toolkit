PREFIX ?= $(HOME)/.local
BINDIR ?= $(PREFIX)/bin

.PHONY: install uninstall check

install:
	install -d "$(BINDIR)"
	install -m 755 bin/extract-archives-cleanup "$(BINDIR)/extract-archives-cleanup"
	install -m 755 bin/find-leftover-archives "$(BINDIR)/find-leftover-archives"

uninstall:
	rm -f "$(BINDIR)/extract-archives-cleanup"
	rm -f "$(BINDIR)/find-leftover-archives"

check:
	python3 -m py_compile bin/extract-archives-cleanup
	bash -n bin/find-leftover-archives
	bash tests/syntax-check.sh
