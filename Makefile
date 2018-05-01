include config.mk

.PHONY: tomatoware toolchain

all: tomatoware

tomatoware: toolchain
	./scripts/base.sh
	./scripts/buildroot.sh
	./scripts/asterisk.sh
	./scripts/package.sh

toolchain:
	./scripts/toolchain.sh


################################
.PHONY: test

test:
	./scripts/base.sh

################################

.PHONY: toolchain-clean clean

toolchain-clean:
	rm -rf toolchain
	rm -rf src/gcc
	rm -rf /opt/tomatoware/*-soft-*

clean:
	rm -rf mmc usr home lib var
	./scripts/clean.sh
	rm -f .packaged

#	git clean -fdxq && git reset --hard
