include config.mk

tomatoware: toolchain
	./scripts/base.sh
	./scripts/buildroot.sh
	./scripts/asterisk.sh
	./scripts/package.sh

toolchain:
	./scripts/toolchain.sh

reset:
	cd src
	find . -name .extracted | xargs -r rm -f || true
	find . -name .patched | xargs -r rm -f || true
	find . -name .built | xargs -r rm -f || true
	find . -name .configured | -r xargs rm -f || true
	find . -name .installed | -r xargs rm -f || true

toolchain-clean:
	rm -rf toolchain
	rm -rf /opt/tomatoware/$(DESTARCH)-$(FLOAT)$(subst /,-,$(PREFIX))

clean: toolchain-clean
	rm -rf mmc usr home lib var
	./scripts/clean.sh


#	git clean -fdxq && git reset --hard
