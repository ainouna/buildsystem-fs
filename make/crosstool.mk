$(TARGET_DIR)/lib/libc.so.6:
	if test -e $(CROSS_BASE)/$(TARGET)/sys-root/lib; then \
		cp -a $(CROSS_BASE)/$(TARGET)/sys-root/lib/*so* $(TARGET_DIR)/lib; \
	else \
		cp -a $(CROSS_BASE)/$(TARGET)/lib/*so* $(TARGET_DIR)/lib; \
	fi

#
# crosstool-ng
#
ifeq ($(BS_GCC_VER), $(filter $(BS_GCC_VER), 8.4.0 9.3.0 10.3.0 11.1.0))
#CROSSTOOL_NG_VER     = 4e5bc436 # 10.2.0
#CROSSTOOL_NG_VER     = f582f1c2 # 10.3.0
CROSSTOOL_NG_VER     =  f284f414
else
CROSSTOOL_NG_VER     = 7bd6bb00
endif
CROSSTOOL_NG_DIR     = crosstool-ng.git
CROSSTOOL_NG_SOURCE  = $(CROSSTOOL_NG_DIR)
CROSSTOOL_NG_URL     = https://github.com/crosstool-ng/crosstool-ng
CROSSTOOL_NG_CONFIG  = crosstool-ng-$(BOXARCH)-$(CROSSTOOL_GCC_VER)
CROSSTOOL_NG_BACKUP  = $(ARCHIVE)/$(CROSSTOOL_NG_CONFIG)-kernel-$(KERNEL_VER)-backup.tar.gz

# -----------------------------------------------------------------------------

ifeq ($(wildcard $(CROSS_BASE)/build.log.bz2),)
CROSSTOOL = crosstool
crosstool:
	make MAKEFLAGS=--no-print-directory crosstool-ng
	if [ ! -e $(CROSSTOOL_NG_BACKUP) ]; then \
		make crosstool-backup; \
	fi;

crosstool-ng: directories kernel.do_prepare $(ARCHIVE)/$(KERNEL_SRC)
	$(START_BUILD)
	$(REMOVE)/$(CROSSTOOL_NG_DIR)
	$(GET-GIT-SOURCE) $(CROSSTOOL_NG_URL) $(ARCHIVE)/$(CROSSTOOL_NG_SOURCE)
	$(CPDIR)/$(CROSSTOOL_NG_DIR)
	unset CONFIG_SITE LIBRARY_PATH CPATH C_INCLUDE_PATH PKG_CONFIG_PATH CPLUS_INCLUDE_PATH INCLUDE; \
	$(CHDIR)/$(CROSSTOOL_NG_DIR); \
		git checkout -q $(CROSSTOOL_NG_VER); \
		$(INSTALL_DATA) $(PATCHES)/ct-ng/$(CROSSTOOL_NG_CONFIG).config .config; \
		NUM_CPUS=$$(expr `getconf _NPROCESSORS_ONLN` \* 2); \
		MEM_512M=$$(awk '/MemTotal/ {M=int($$2/1024/512); print M==0?1:M}' /proc/meminfo); \
		test $$NUM_CPUS -gt $$MEM_512M && NUM_CPUS=$$MEM_512M; \
		test $$NUM_CPUS = 0 && NUM_CPUS=1; \
		sed -i "s@^CT_PARALLEL_JOBS=.*@CT_PARALLEL_JOBS=$$NUM_CPUS@" .config; \
		\
		export CT_NG_ARCHIVE=$(ARCHIVE); \
		export CT_NG_BASE_DIR=$(CROSS_BASE); \
		export CT_NG_CUSTOM_KERNEL=$(KERNEL_DIR); \
		test -f ./configure || ./bootstrap && \
		./configure --enable-local; \
		MAKELEVEL=0 make; \
		chmod 0755 ct-ng; \
		\
		./ct-ng build
	test -e $(CROSS_BASE)/$(TARGET)/lib || ln -sf sys-root/lib $(CROSS_BASE)/$(TARGET)/
	rm -f $(CROSS_BASE)/$(TARGET)/sys-root/lib/libstdc++.so.6.0.*-gdb.py
	$(REMOVE)/$(CROSSTOOL_NG_DIR)
endif
#		./ct-ng oldconfig; \

# -----------------------------------------------------------------------------

crosstool-config:
	make MAKEFLAGS=--no-print-directory crosstool-ng-config

crosstool-ng-config: directories
	$(REMOVE)/$(CROSSTOOL_NG_DIR)
	$(GET-GIT-SOURCE) $(CROSSTOOL_NG_URL) $(ARCHIVE)/$(CROSSTOOL_NG_SOURCE)
	$(CPDIR)/$(CROSSTOOL_NG_DIR)
	unset CONFIG_SITE; \
	$(CHDIR)/$(CROSSTOOL_NG_DIR); \
		git checkout -q $(CROSSTOOL_NG_VER); \
		$(INSTALL_DATA) $(PATCHES)/ct-ng/$(CROSSTOOL_NG_CONFIG).config .config; \
		test -f ./configure || ./bootstrap && \
		./configure --enable-local; \
		MAKELEVEL=0 make; \
		chmod 0755 ct-ng; \
		./ct-ng menuconfig

# -----------------------------------------------------------------------------

crosstool-upgradeconfig:
	make MAKEFLAGS=--no-print-directory crosstool-ng-upgradeconfig

crosstool-ng-upgradeconfig: directories
	$(REMOVE)/$(CROSSTOOL_NG_DIR)
	$(GET-GIT-SOURCE) $(CROSSTOOL_NG_URL) $(ARCHIVE)/$(CROSSTOOL_NG_SOURCE)
	$(CPDIR)/$(CROSSTOOL_NG_DIR)
	unset CONFIG_SITE; \
	$(CHDIR)/$(CROSSTOOL_NG_DIR); \
		git checkout -q $(CROSSTOOL_NG_VER); \
		$(INSTALL_DATA) $(PATCHES)/ct-ng/$(CROSSTOOL_NG_CONFIG).config .config; \
		test -f ./configure || ./bootstrap && \
		./configure --enable-local; \
		MAKELEVEL=0 make; \
		./ct-ng upgradeconfig

# -----------------------------------------------------------------------------

crosstool-backup:
	if [ -e $(CROSSTOOL_NG_BACKUP) ]; then \
		mv $(CROSSTOOL_NG_BACKUP) $(CROSSTOOL_NG_BACKUP).old; \
	fi; \
	cd $(CROSS_BASE); \
	tar czvf $(CROSSTOOL_NG_BACKUP) *

crosstool-restore: $(CROSSTOOL_NG_BACKUP)
	rm -rf $(CROSS_BASE) ; \
	if [ ! -e $(CROSS_BASE) ]; then \
		mkdir -p $(CROSS_BASE); \
	fi;
	tar xzvf $(CROSSTOOL_NG_BACKUP) -C $(CROSS_BASE)

crosstool-renew:
	ccache -cCz
	make distclean
	rm -rf $(CROSS_BASE)
	make crosstool
