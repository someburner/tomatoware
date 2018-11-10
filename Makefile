include config.mk

.PHONY: tomatoware toolchain

all: tomatoware

tomatoware: toolchain
ifeq ($(LOG_EN),1)
	@rm -f $(LOGFILE)
	@touch $(LOGFILE)
	(./scripts/base.sh >> $(LOGFILE) 2>&1)
	(./scripts/buildroot.sh >> $(LOGFILE) 2>&1)
	(./scripts/asterisk.sh >> $(LOGFILE) 2>&1)
	(./scripts/package.sh >> $(LOGFILE) 2>&1)
else
	./scripts/base.sh
	./scripts/buildroot.sh
	./scripts/asterisk.sh
	./scripts/package.sh
endif

toolchain:
ifeq ($(LOG_EN),1)
	(./scripts/toolchain.sh >> $(LOGFILE) 2>&1)
else
	./scripts/toolchain.sh
endif

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
