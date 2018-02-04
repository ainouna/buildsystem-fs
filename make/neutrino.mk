#
# Makefile to build NEUTRINO
#
$(TARGET_DIR)/var/etc/.version:
	echo "imagename=Neutrino HD" > $@
	echo "homepage=https://github.com/fs-basis" >> $@
	echo "creator=$(MAINTAINER)" >> $@
	echo "docs=https://github.com/fs-basis" >> $@
	echo "forum=https://github.com/fs-basis/neutrino-gui" >> $@
	echo "version=0200`date +%Y%m%d%H%M`" >> $@
	echo "git=`git log | grep "^commit" | wc -l`" >> $@

NEUTRINO_DEPS  = $(D)/bootstrap $(KERNEL) $(D)/system-tools
NEUTRINO_DEPS += $(D)/ncurses $(LIRC) $(D)/libcurl
NEUTRINO_DEPS += $(D)/libpng $(D)/libjpeg $(D)/giflib $(D)/freetype
NEUTRINO_DEPS += $(D)/alsa_utils $(D)/ffmpeg
NEUTRINO_DEPS += $(D)/libfribidi $(D)/libsigc $(D)/libdvbsi $(D)/libusb
NEUTRINO_DEPS += $(D)/pugixml $(D)/libopenthreads
NEUTRINO_DEPS += $(D)/lua $(D)/luaexpat $(D)/luacurl $(D)/luasocket $(D)/luafeedparser $(D)/luasoap $(D)/luajson
NEUTRINO_DEPS += $(LOCAL_NEUTRINO_DEPS)

ifeq ($(BOXTYPE), $(filter $(BOXTYPE), atevio7500 spark spark7162 ufs912 ufs913 ufs910))
NEUTRINO_DEPS += $(D)/ntfs_3g
ifneq ($(BOXTYPE), $(filter $(BOXTYPE), ufs910))
NEUTRINO_DEPS += $(D)/mtd_utils $(D)/parted
endif
#NEUTRINO_DEPS +=  $(D)/minidlna
endif

ifeq ($(BOXARCH), arm)
NEUTRINO_DEPS += $(D)/ntfs_3g
NEUTRINO_DEPS += $(D)/mc
endif

ifeq ($(IMAGE), neutrino-wlandriver)
NEUTRINO_DEPS += $(D)/wpa_supplicant $(D)/wireless_tools
endif

NEUTRINO_DEPS2 = $(D)/libid3tag $(D)/libmad $(D)/flac

N_CFLAGS       = -Wall -W -Wshadow -pipe -Os
N_CFLAGS      += -D__KERNEL_STRICT_NAMES
N_CFLAGS      += -D__STDC_FORMAT_MACROS
N_CFLAGS      += -D__STDC_CONSTANT_MACROS
N_CFLAGS      += -fno-strict-aliasing -funsigned-char -ffunction-sections -fdata-sections
#N_CFLAGS      += -DCPU_FREQ
N_CFLAGS      += $(LOCAL_NEUTRINO_CFLAGS)

N_CPPFLAGS     = -I$(TARGET_DIR)/usr/include
N_CPPFLAGS    += -ffunction-sections -fdata-sections

ifeq ($(BOXARCH), arm)
N_CPPFLAGS    += -I$(CROSS_BASE)/$(TARGET)/sys-root/usr/include
endif

ifeq ($(BOXARCH), sh4)
N_CPPFLAGS    += -I$(DRIVER_DIR)/bpamem
N_CPPFLAGS    += -I$(KERNEL_DIR)/include
endif

ifeq ($(BOXTYPE), $(filter $(BOXTYPE), spark spark7162))
N_CPPFLAGS += -I$(DRIVER_DIR)/frontcontroller/aotom_spark
endif

LH_CONFIG_OPTS =
ifeq ($(MEDIAFW), gstreamer)
NEUTRINO_DEPS  += $(D)/gst_plugins_dvbmediasink
N_CPPFLAGS     += $(shell $(PKG_CONFIG) --cflags --libs gstreamer-1.0)
N_CPPFLAGS     += $(shell $(PKG_CONFIG) --cflags --libs gstreamer-audio-1.0)
N_CPPFLAGS     += $(shell $(PKG_CONFIG) --cflags --libs gstreamer-video-1.0)
N_CPPFLAGS     += $(shell $(PKG_CONFIG) --cflags --libs glib-2.0)
LH_CONFIG_OPTS += --enable-gstreamer_10=yes
endif

N_CONFIG_OPTS  = $(LOCAL_NEUTRINO_BUILD_OPTIONS)
N_CONFIG_OPTS += --enable-freesatepg
N_CONFIG_OPTS += --enable-lua
N_CONFIG_OPTS += --enable-giflib
N_CONFIG_OPTS += --with-tremor
N_CONFIG_OPTS += --enable-ffmpegdec
#N_CONFIG_OPTS += --enable-pip
#N_CONFIG_OPTS += --disable-webif
N_CONFIG_OPTS += --disable-upnp
#N_CONFIG_OPTS += --disable-tangos
N_CONFIG_OPTS += --enable-pugixml
ifeq ($(BOXARCH), arm)
N_CONFIG_OPTS += --enable-reschange
endif

ifeq ($(FLAVOUR), neutrino-mp-max)
GIT_URL      = https://bitbucket.org/max_10
NEUTRINO_MP  = neutrino-mp-max
LIBSTB_HAL   = libstb-hal-max
N_BRANCH    ?= master
L_BRANCH    ?= master
N_PATCHES    = $(NEUTRINO_MP_MAX_PATCHES)
L_PATCHE     = $(NEUTRINO_MP_LIBSTB_MAX_PATCHES)
else ifeq  ($(FLAVOUR), neutrino-mp-ni)
GIT_URL      = https://bitbucket.org/neutrino-images
NEUTRINO_MP  = ni-neutrino-hd
LIBSTB_HAL   = ni-libstb-hal-next
N_BRANCH    ?= master
L_BRANCH    ?= master
N_PATCHES    = $(NEUTRINO_MP_NI_PATCHES)
L_PATCHE     = $(NEUTRINO_MP_LIBSTB_NI_PATCHES)
else ifeq  ($(FLAVOUR), neutrino-mp-tangos)
GIT_URL      = https://github.com/TangoCash
NEUTRINO_MP  = neutrino-mp-tangos
LIBSTB_HAL   = libstb-hal-tangos
N_BRANCH    ?= master
L_BRANCH    ?= master
N_PATCHES    = $(NEUTRINO_MP_TANGOS_PATCHES)
L_PATCHE     = $(NEUTRINO_MP_LIBSTB_TANGOS_PATCHES)
else ifeq  ($(FLAVOUR), neutrino-mp-ddt)
GIT_URL      = https://github.com/Duckbox-Developers
NEUTRINO_MP  = neutrino-mp-ddt
LIBSTB_HAL   = libstb-hal-ddt
N_BRANCH    ?= master
L_BRANCH    ?= master
N_PATCHES    = $(NEUTRINO_MP_DDT_PATCHES)
L_PATCHE     = $(NEUTRINO_MP_LIBSTB_DDT_PATCHES)
else ifeq  ($(FLAVOUR), neutrino-mp-fs)
GIT_URL      = https://github.com/fs-basis
NEUTRINO_MP  = neutrino-mp-fs
LIBSTB_HAL   = libstb-hal-fs
N_BRANCH    ?= current
L_BRANCH    ?= master
N_PATCHES    = $(FS_NEUTRINO_CURRENT_PATCHES)
L_PATCHE     = $(LIBSTB_HAL_FS_PATCHES)
else ifeq  ($(FLAVOUR), neutrino-mp-matze)
GIT_URL      = https://github.com/fs-basis
NEUTRINO_MP  = neutrino-mp-fs
LIBSTB_HAL   = libstb-hal-fs
N_BRANCH    ?= udog
L_BRANCH    ?= master
N_PATCHES    = $(NEUTRINO_MATZE_PATCHES)
L_PATCHE     = $(LIBSTB_HAL_FS_PATCHES)
endif

OBJDIR = $(BUILD_TMP)
N_OBJDIR = $(OBJDIR)/$(NEUTRINO_MP)
LH_OBJDIR = $(OBJDIR)/$(LIBSTB_HAL)

################################################################################
#
# libstb-hal
#

$(D)/libstb-hal.do_prepare:
	$(START_BUILD)
	rm -rf $(SOURCE_DIR)/$(LIBSTB_HAL)
	rm -rf $(SOURCE_DIR)/$(LIBSTB_HAL).org
	rm -rf $(LH_OBJDIR)
	[ -d "$(ARCHIVE)/$(LIBSTB_HAL).git" ] && \
	(cd $(ARCHIVE)/$(LIBSTB_HAL).git; git pull;); \
	[ -d "$(ARCHIVE)/$(LIBSTB_HAL).git" ] || \
	git clone $(GIT_URL)/$(LIBSTB_HAL).git $(ARCHIVE)/$(LIBSTB_HAL).git; \
	cp -ra $(ARCHIVE)/$(LIBSTB_HAL).git $(SOURCE_DIR)/$(LIBSTB_HAL);\
	(cd $(SOURCE_DIR)/$(LIBSTB_HAL); git checkout $(L_BRANCH);); \
	cp -ra $(SOURCE_DIR)/$(LIBSTB_HAL) $(SOURCE_DIR)/$(LIBSTB_HAL).org
	set -e; cd $(SOURCE_DIR)/$(LIBSTB_HAL); \
		$(call apply_patches,$(L_PATCHE))
	@touch $@

$(D)/libstb-hal.config.status: | $(NEUTRINO_DEPS)
	rm -rf $(LH_OBJDIR)
	test -d $(LH_OBJDIR) || mkdir -p $(LH_OBJDIR)
	cd $(LH_OBJDIR); \
		$(SOURCE_DIR)/$(LIBSTB_HAL)/autogen.sh; \
		$(BUILDENV) \
		$(SOURCE_DIR)/$(LIBSTB_HAL)/configure \
			--enable-silent-rules \
			--host=$(TARGET) \
			--build=$(BUILD) \
			--prefix= \
			--with-target=cdk \
			--with-boxtype=$(BOXTYPE) \
			$(LH_CONFIG_OPTS) \
			PKG_CONFIG=$(PKG_CONFIG) \
			PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
			CFLAGS="$(N_CFLAGS)" CXXFLAGS="$(N_CFLAGS)" CPPFLAGS="$(N_CPPFLAGS)"
	@touch $@

$(D)/libstb-hal.do_compile: $(D)/libstb-hal.config.status
	cd $(SOURCE_DIR)/libstb-hal; \
		$(MAKE) -C $(LH_OBJDIR) all DESTDIR=$(TARGET_DIR)
	@touch $@

$(D)/libstb-hal: $(D)/libstb-hal.do_prepare $(D)/libstb-hal.do_compile
	$(MAKE) -C $(LH_OBJDIR) install DESTDIR=$(TARGET_DIR)
	$(TOUCH)

libstb-hal-clean:
	rm -f $(D)/libstb-hal
	rm -f $(D)/libstb-hal.config.status
	cd $(LH_OBJDIR); \
		$(MAKE) -C $(LH_OBJDIR) distclean

libstb-hal-distclean:
	rm -rf $(LH_OBJDIR)
	rm -f $(D)/libstb-hal*

################################################################################
#
# neutrino-mp
#
$(D)/neutrino-mp-plugins.do_prepare \
$(D)/neutrino-mp.do_prepare: | $(NEUTRINO_DEPS) $(D)/libstb-hal
	$(START_BUILD)
	rm -rf $(SOURCE_DIR)/$(NEUTRINO_MP)
	rm -rf $(SOURCE_DIR)/$(NEUTRINO_MP).org
	rm -rf $(N_OBJDIR)
	[ -d "$(ARCHIVE)/$(NEUTRINO_MP).git" ] && \
	(cd $(ARCHIVE)/$(NEUTRINO_MP).git; git pull;); \
	[ -d "$(ARCHIVE)/$(NEUTRINO_MP).git" ] || \
	git clone $(GIT_URL)/$(NEUTRINO_MP).git $(ARCHIVE)/$(NEUTRINO_MP).git; \
	cp -ra $(ARCHIVE)/$(NEUTRINO_MP).git $(SOURCE_DIR)/$(NEUTRINO_MP); \
	(cd $(SOURCE_DIR)/$(NEUTRINO_MP); git checkout $(N_BRANCH);); \
	cp -ra $(SOURCE_DIR)/$(NEUTRINO_MP) $(SOURCE_DIR)/$(NEUTRINO_MP).org
	set -e; cd $(SOURCE_DIR)/$(NEUTRINO_MP); \
		$(call apply_patches,$(N_PATCHES))
	@touch $@

$(D)/neutrino-mp.config.status \
$(D)/neutrino-mp-plugins.config.status:
	rm -rf $(N_OBJDIR)
	test -d $(N_OBJDIR) || mkdir -p $(N_OBJDIR)
	cd $(N_OBJDIR); \
		$(SOURCE_DIR)/$(NEUTRINO_MP)/autogen.sh; \
		$(BUILDENV) \
		$(SOURCE_DIR)/$(NEUTRINO_MP)/configure \
			--enable-silent-rules \
			--build=$(BUILD) \
			--host=$(TARGET) \
			$(N_CONFIG_OPTS) \
			--with-boxtype=$(BOXTYPE) \
			--with-libdir=/usr/lib \
			--with-datadir=/share/tuxbox \
			--with-fontdir=/share/fonts \
			--with-fontdir_var=/var/tuxbox/fonts \
			--with-configdir=/var/tuxbox/config \
			--with-gamesdir=/var/tuxbox/games \
			--with-iconsdir=/share/tuxbox/neutrino/icons \
			--with-iconsdir_var=/var/tuxbox/icons \
			--with-localedir=/share/tuxbox/neutrino/locale \
			--with-localedir_var=/var/tuxbox/locale \
			--with-plugindir=/var/tuxbox/plugins \
			--with-plugindir_var=/var/tuxbox/plugins \
			--with-luaplugindir=/var/tuxbox/plugins \
			--with-private_httpddir=/share/tuxbox/neutrino/httpd \
			--with-public_httpddir=/var/tuxbox/httpd \
			--with-themesdir=/share/tuxbox/neutrino/themes \
			--with-themesdir_var=/var/tuxbox/themes \
			--with-webtvdir=/share/tuxbox/neutrino/webtv \
			--with-webtvdir_var=/var/tuxbox/plugins/webtv \
			--with-stb-hal-includes=$(SOURCE_DIR)/$(LIBSTB_HAL)/include \
			--with-stb-hal-build=$(LH_OBJDIR) \
			PKG_CONFIG=$(PKG_CONFIG) \
			PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
			CFLAGS="$(N_CFLAGS)" CXXFLAGS="$(N_CFLAGS)" CPPFLAGS="$(N_CPPFLAGS)"
		+make $(SOURCE_DIR)/$(NEUTRINO_MP)/src/gui/version.h
	@touch $@

$(SOURCE_DIR)/$(NEUTRINO_MP)/src/gui/version.h:
	@rm -f $@
	echo '#define BUILT_DATE "'`date`'"' > $@
	@if test -d $(SOURCE_DIR)/$(LIBSTB_HAL); then \
		pushd $(SOURCE_DIR)/$(LIBSTB_HAL); \
		HAL_REV=$$(git log | grep "^commit" | wc -l); \
		popd; \
		pushd $(SOURCE_DIR)/$(NEUTRINO_MP); \
		NMP_REV=$$(git log | grep "^commit" | wc -l); \
		popd; \
		pushd $(BASE_DIR); \
		DDT_REV=$$(git log | grep "^commit" | wc -l); \
		popd; \
		echo '#define VCS "DDT-rev'$$DDT_REV'_HAL-rev'$$HAL_REV'_NMP-rev'$$NMP_REV'"' >> $@; \
	fi

$(D)/neutrino-mp-plugins.do_compile \
$(D)/neutrino-mp.do_compile:
	cd $(SOURCE_DIR)/$(NEUTRINO_MP); \
		$(MAKE) -C $(N_OBJDIR) all
	@touch $@

mp \
neutrino-mp: $(D)/neutrino-mp.do_prepare $(D)/neutrino-mp.config.status $(D)/neutrino-mp.do_compile
	$(MAKE) -C $(N_OBJDIR) install DESTDIR=$(TARGET_DIR)
	make $(TARGET_DIR)/var/etc/.version
	touch $(D)/$(notdir $@)
	make neutrino-release
	$(TUXBOX_CUSTOMIZE)

mp-clean \
neutrino-mp-clean: neutrino-cdkroot-clean
	rm -f $(D)/neutrino-mp
	rm -f $(D)/neutrino-mp.config.status
	rm -f $(SOURCE_DIR)/$(NEUTRINO_MP)/src/gui/version.h
	cd $(N_OBJDIR); \
		$(MAKE) -C $(N_OBJDIR) distclean

mp-distclean \
neutrino-mp-distclean: neutrino-cdkroot-clean
	rm -rf $(N_OBJDIR)
	rm -f $(D)/neutrino-mp*

mpp \
neutrino-mp-plugins: $(D)/neutrino-mp-plugins.do_prepare $(D)/neutrino-mp-plugins.config.status $(D)/neutrino-mp-plugins.do_compile
	$(MAKE) -C $(N_OBJDIR) install DESTDIR=$(TARGET_DIR)
	make $(TARGET_DIR)/var/etc/.version
	make $(NEUTRINO_PLUGINS)
	touch $(D)/$(notdir $@)
	make neutrino-release
	$(TUXBOX_CUSTOMIZE)

mpp-clean \
neutrino-mp-plugins-clean: neutrino-cdkroot-clean
	rm -f $(D)/neutrino-mp-plugins
	rm -f $(D)/neutrino-mp-plugins.config.status
	rm -f $(SOURCE_DIR)/$(NEUTRINO_MP)/src/gui/version.h
	make neutrino-mp-plugin-clean
	cd $(N_OBJDIR); \
		$(MAKE) -C $(N_OBJDIR) distclean

mpp-distclean \
neutrino-mp-plugins-distclean: neutrino-cdkroot-clean
	rm -rf $(N_OBJDIR)
	rm -f $(D)/neutrino-mp-plugins*
	make neutrino-mp-plugin-distclean

################################################################################
#
# neutrino-hd2
#
ifeq ($(BOXTYPE), spark)
NHD2_OPTS = --enable-4digits
else ifeq ($(BOXTYPE), spark7162)
NHD2_OPTS =
else
NHD2_OPTS = --enable-ci
endif

NEUTRINO_HD2_PATCHES =

$(D)/neutrino-hd2.do_prepare: | $(NEUTRINO_DEPS) $(NEUTRINO_DEPS2)
	$(START_BUILD)
	rm -rf $(SOURCE_DIR)/neutrino-hd2
	rm -rf $(SOURCE_DIR)/neutrino-hd2.org
	rm -rf $(SOURCE_DIR)/neutrino-hd2.git
	[ -d "$(ARCHIVE)/neutrino-hd2.git" ] && \
	(cd $(ARCHIVE)/neutrino-hd2.git; git pull;); \
	[ -d "$(ARCHIVE)/neutrino-hd2.git" ] || \
	git clone https://github.com/mohousch/neutrinohd2.git $(ARCHIVE)/neutrino-hd2.git; \
	cp -ra $(ARCHIVE)/neutrino-hd2.git $(SOURCE_DIR)/neutrino-hd2.git; \
	ln -s $(SOURCE_DIR)/neutrino-hd2.git/nhd2-exp $(SOURCE_DIR)/neutrino-hd2;\
	cp -ra $(SOURCE_DIR)/neutrino-hd2.git/nhd2-exp $(SOURCE_DIR)/neutrino-hd2.org
	set -e; cd $(SOURCE_DIR)/neutrino-hd2; \
		$(call apply_patches,$(NEUTRINO_HD2_PATCHES))
	@touch $@

$(D)/neutrino-hd2.config.status:
	cd $(SOURCE_DIR)/neutrino-hd2; \
		./autogen.sh; \
		$(BUILDENV) \
		./configure \
			--build=$(BUILD) \
			--host=$(TARGET) \
			--enable-silent-rules \
			--with-boxtype=$(BOXTYPE) \
			--with-datadir=/share/tuxbox \
			--with-fontdir=/share/fonts \
			--with-configdir=/var/tuxbox/config \
			--with-gamesdir=/var/tuxbox/games \
			--with-plugindir=/var/tuxbox/plugins \
			--with-isocodesdir=/usr/local/share/iso-codes \
			$(NHD2_OPTS) \
			--enable-scart \
			PKG_CONFIG=$(PKG_CONFIG) \
			PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
			CPPFLAGS="$(N_CPPFLAGS)" LDFLAGS="$(TARGET_LDFLAGS)"
	@touch $@

$(D)/neutrino-hd2.do_compile: $(D)/neutrino-hd2.config.status
	cd $(SOURCE_DIR)/neutrino-hd2; \
		$(MAKE) all
	@touch $@

neutrino-hd2: $(D)/neutrino-hd2.do_prepare $(D)/neutrino-hd2.do_compile
	$(MAKE) -C $(SOURCE_DIR)/neutrino-hd2 install DESTDIR=$(TARGET_DIR)
	make $(TARGET_DIR)/var/etc/.version
	touch $(D)/$(notdir $@)
	make neutrino-release
	$(TUXBOX_CUSTOMIZE)

nhd2 \
neutrino-hd2-plugins: $(D)/neutrino-hd2.do_prepare $(D)/neutrino-hd2.do_compile
	$(MAKE) -C $(SOURCE_DIR)/neutrino-hd2 install DESTDIR=$(TARGET_DIR)
	make $(TARGET_DIR)/var/etc/.version
	touch $(D)/$(notdir $@)
	make neutrino-hd2-plugins.build
	make neutrino-release
	$(TUXBOX_CUSTOMIZE)

nhd2-clean \
neutrino-hd2-clean: neutrino-cdkroot-clean
	rm -f $(D)/neutrino-hd2
	rm -f $(D)/neutrino-hd2.config.status
	cd $(SOURCE_DIR)/neutrino-hd2; \
		$(MAKE) clean

nhd2-distclean \
neutrino-hd2-distclean: neutrino-cdkroot-clean
	rm -f $(D)/neutrino-hd2*
	rm -f $(D)/neutrino-hd2-plugins*

################################################################################
neutrino-cdkroot-clean:
	[ -e $(TARGET_DIR)/usr/local/bin ] && cd $(TARGET_DIR)/usr/local/bin && find -name '*' -delete || true
	[ -e $(TARGET_DIR)/usr/local/share/iso-codes ] && cd $(TARGET_DIR)/usr/local/share/iso-codes && find -name '*' -delete || true
	[ -e $(TARGET_DIR)/usr/share/tuxbox/neutrino ] && cd $(TARGET_DIR)/usr/share/tuxbox/neutrino && find -name '*' -delete || true
	[ -e $(TARGET_DIR)/usr/share/fonts ] && cd $(TARGET_DIR)/usr/share/fonts && find -name '*' -delete || true
	[ -e $(TARGET_DIR)/var/tuxbox ] && cd $(TARGET_DIR)/var/tuxbox && find -name '*' -delete || true

dual:
	make nhd2
	make neutrino-cdkroot-clean
	make mp

dual-clean:
	make nhd2-clean
	make mp-clean

dual-distclean:
	make nhd2-distclean
	make mp-distclean

PHONY += $(TARGET_DIR)/var/etc/.version
PHONY += $(SOURCE_DIR)/$(NEUTRINO_MP)/src/gui/version.h
