#
STM_RELOCATE     = /opt/STM/STLinux-2.4

# updates / downloads
STL_FTP          = http://archive.stlinux.com/stlinux/2.4
STL_FTP_UPD_SRC  = $(STL_FTP)/updates/SRPMS
STL_FTP_UPD_SH4  = $(STL_FTP)/updates/RPMS/sh4
STL_FTP_UPD_HOST = $(STL_FTP)/updates/RPMS/host
STL_ARCHIVE      = $(ARCHIVE)/stlinux
STL_GET          = $(WGET)/stlinux

## ordering is important here. The /host/ rule must stay before the less
## specific %.sh4/%.i386/%.noarch rule. No idea if this is portable or
## even reliable :-(
$(STL_ARCHIVE)/stlinux24-host-%.i386.rpm \
$(STL_ARCHIVE)/stlinux24-host-%noarch.rpm:
	$(STL_GET) $(STL_FTP_UPD_HOST)/$(subst $(STL_ARCHIVE)/,"",$@)

$(STL_ARCHIVE)/stlinux24-host-%.src.rpm:
	$(STL_GET) $(STL_FTP_UPD_SRC)/$(subst $(STL_ARCHIVE)/,"",$@)

$(STL_ARCHIVE)/stlinux24-sh4-%.sh4.rpm \
$(STL_ARCHIVE)/stlinux24-cross-%.i386.rpm \
$(STL_ARCHIVE)/stlinux24-sh4-%.noarch.rpm:
	$(STL_GET) $(STL_FTP_UPD_SH4)/$(subst $(STL_ARCHIVE)/,"",$@)

#
# install the RPMs
#

# 4.6.3
#BINUTILS_VERSION = 2.22-64
#GCC_VERSION      = 4.6.3-111
#LIBGCC_VERSION   = 4.6.3-111
#GLIBC_VERSION    = 2.10.2-42

# 4.8.4
BINUTILS_VERSION = 2.24.51.0.3-76
GCC_VERSION      = 4.8.4-139
LIBGCC_VERSION   = 4.8.4-148
GLIBC_VERSION    = 2.14.1-59

crosstool-rpminstall: \
$(STL_ARCHIVE)/stlinux24-cross-sh4-binutils-$(BINUTILS_VERSION).i386.rpm \
$(STL_ARCHIVE)/stlinux24-cross-sh4-binutils-dev-$(BINUTILS_VERSION).i386.rpm \
$(STL_ARCHIVE)/stlinux24-cross-sh4-cpp-$(GCC_VERSION).i386.rpm \
$(STL_ARCHIVE)/stlinux24-cross-sh4-gcc-$(GCC_VERSION).i386.rpm \
$(STL_ARCHIVE)/stlinux24-cross-sh4-g++-$(GCC_VERSION).i386.rpm \
$(STL_ARCHIVE)/stlinux24-sh4-linux-kernel-headers-$(STM_KERNEL_HEADERS_VERSION).noarch.rpm \
$(STL_ARCHIVE)/stlinux24-sh4-glibc-$(GLIBC_VERSION).sh4.rpm \
$(STL_ARCHIVE)/stlinux24-sh4-glibc-dev-$(GLIBC_VERSION).sh4.rpm \
$(STL_ARCHIVE)/stlinux24-sh4-libgcc-$(LIBGCC_VERSION).sh4.rpm \
$(STL_ARCHIVE)/stlinux24-sh4-libstdc++-$(LIBGCC_VERSION).sh4.rpm \
$(STL_ARCHIVE)/stlinux24-sh4-libstdc++-dev-$(LIBGCC_VERSION).sh4.rpm
	unpack-rpm.sh $(BUILD_TMP) $(STM_RELOCATE)/devkit/sh4 $(CROSS_DIR) \
		$^
	touch $(D)/$(notdir $@)

crosstool: directories driver-symlink \
$(HOST_DIR)/bin/unpack-rpm.sh \
crosstool-rpminstall
	set -e; cd $(CROSS_DIR); rm -f sh4-linux/sys-root; ln -s ../target sh4-linux/sys-root; \
	if [ -e $(CROSS_DIR)/target/usr/lib/libstdc++.la ]; then \
		sed -i "s,^libdir=.*,libdir='$(CROSS_DIR)/target/usr/lib'," $(CROSS_DIR)/target/usr/lib/lib{std,sup}c++.la; \
	fi
	if test -e $(CROSS_DIR)/target/usr/lib/libstdc++.so; then \
		cp -a $(CROSS_DIR)/target/usr/lib/libstdc++.s*[!y] $(TARGET_DIR)/lib; \
		cp -a $(CROSS_DIR)/target/usr/lib/libdl.so $(TARGET_DIR)/usr/lib; \
		cp -a $(CROSS_DIR)/target/usr/lib/libm.so $(TARGET_DIR)/usr/lib; \
		cp -a $(CROSS_DIR)/target/usr/lib/librt.so $(TARGET_DIR)/usr/lib; \
		cp -a $(CROSS_DIR)/target/usr/lib/libutil.so $(TARGET_DIR)/usr/lib; \
		cp -a $(CROSS_DIR)/target/usr/lib/libpthread.so $(TARGET_DIR)/usr/lib; \
		cp -a $(CROSS_DIR)/target/usr/lib/libresolv.so $(TARGET_DIR)/usr/lib; \
		ln -sf $(CROSS_DIR)/target/usr/lib/libc.so $(TARGET_DIR)/usr/lib/libc.so; \
		ln -sf $(CROSS_DIR)/target/usr/lib/libc_nonshared.a $(TARGET_DIR)/usr/lib/libc_nonshared.a; \
	fi
	if test -e $(CROSS_DIR)/target/lib; then \
		cp -a $(CROSS_DIR)/target/lib/*so* $(TARGET_DIR)/lib; \
	fi
	if test -e $(CROSS_DIR)/target/sbin/ldconfig; then \
		cp -a $(CROSS_DIR)/target/sbin/ldconfig $(TARGET_DIR)/sbin; \
		cp -a $(CROSS_DIR)/target/etc/ld.so.conf $(TARGET_DIR)/etc; \
		cp -a $(CROSS_DIR)/target/etc/host.conf $(TARGET_DIR)/etc; \
	fi
	@touch $(D)/$(notdir $@)

#
# crosstool-ng
#
CROSSTOOL_NG_VERSION = 1.22.0
CROSSTOOL_NG_SOURCE = crosstool-ng-$(CROSSTOOL_NG_VERSION).tar.xz

$(ARCHIVE)/$(CROSSTOOL_NG_SOURCE):
	$(WGET) http://crosstool-ng.org/download/crosstool-ng/$(CROSSTOOL_NG_SOURCE)

crosstool-ng: directories $(ARCHIVE)/$(CROSSTOOL_NG_SOURCE)
	make $(BUILD_TMP)
	if [ ! -e $(CROSS_DIR)) ]; then \
		mkdir -p $(CROSS_DIR); \
	fi;
	$(REMOVE)/crosstool-ng
	$(UNTAR)/$(CROSSTOOL_NG_SOURCE)
	set -e; unset CONFIG_SITE; cd $(BUILD_TMP)/crosstool-ng; \
		cp -a $(PATCHES)/crosstool-ng-$(CROSSTOOL_NG_VERSION)-$(BOXARCH).config .config; \
		NUM_CPUS=$$(expr `getconf _NPROCESSORS_ONLN` \* 2); \
		MEM_512M=$$(awk '/MemTotal/ {M=int($$2/1024/512); print M==0?1:M}' /proc/meminfo); \
		test $$NUM_CPUS -gt $$MEM_512M && NUM_CPUS=$$MEM_512M; \
		test $$NUM_CPUS = 0 && NUM_CPUS=1; \
		sed -i "s@^CT_PARALLEL_JOBS=.*@CT_PARALLEL_JOBS=$$NUM_CPUS@" .config; \
		export NG_ARCHIVE=$(ARCHIVE); \
		export NG_BASE_DIR=$(BASE_DIR); \
		export LD_LIBRARY_PATH= ; \
		test -f ./configure || ./bootstrap; \
		./configure --enable-local; \
		MAKELEVEL=0 make; \
		./ct-ng oldconfig; \
		./ct-ng build
	chmod -R +w $(CROSS_DIR)
	test -e $(CROSS_DIR)/$(TARGET)/lib && mv $(CROSS_DIR)/$(TARGET)/lib $(CROSS_DIR)/$(TARGET)/lib.x
	test -e $(CROSS_DIR)/$(TARGET)/lib || ln -sf sys-root/lib $(CROSS_DIR)/$(TARGET)/
	rm -f $(CROSS_DIR)/$(TARGET)/sys-root/lib/libstdc++.so.6.0.20-gdb.py
	$(REMOVE)/crosstool-ng

crossmenuconfig: directories $(ARCHIVE)/$(CROSSTOOL_NG_SOURCE)
	$(REMOVE)/crosstool-ng
	$(UNTAR)/$(CROSSTOOL_NG_SOURCE)
	set -e; unset CONFIG_SITE; cd $(BUILD_TMP)/crosstool-ng; \
		cp -a $(PATCHES)/crosstool-ng-$(CROSSTOOL_NG_VERSION)-$(BOXARCH).config .config; \
		test -f ./configure || ./bootstrap && \
		./configure --enable-local; \
		MAKELEVEL=0 make; \
		chmod 0755 ct-ng; \
		./ct-ng menuconfig

