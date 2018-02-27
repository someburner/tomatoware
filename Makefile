include config.mk

tomatoware: toolchain
	./scripts/base.sh
	./scripts/buildroot.sh
	./scripts/asterisk.sh
	./scripts/package.sh

toolchain:
	./scripts/toolchain.sh

toolchain-clean:
	rm -rf toolchain
	rm -rf src/gcc
	rm -rf /opt/tomatoware/*-soft-*

clean: toolchain-clean
	rm -rf mmc usr home lib var
	./scripts/clean.sh


#	git clean -fdxq && git reset --hard
