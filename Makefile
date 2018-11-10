include config.mk

.PHONY: tomatoware toolchain

all: tomatoware

tomatoware: toolchain
	@rm -f $(LOGFILE)
	@touch $(LOGFILE)
	(./scripts/base.sh >> $(LOGFILE) 2>&1)
	(./scripts/buildroot.sh >> $(LOGFILE) 2>&1)
	(./scripts/asterisk.sh >> $(LOGFILE) 2>&1)
	(./scripts/package.sh >> $(LOGFILE) 2>&1)

toolchain:
	(./scripts/toolchain.sh >> $(LOGFILE) 2>&1)


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
