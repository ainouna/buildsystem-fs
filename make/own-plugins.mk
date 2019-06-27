#
# Makefile to plugins
#

#
# plugins
#
NEUTRINO_PLUGINS  = $(D)/neutrino-mp-plugin
NEUTRINO_PLUGINS += $(LOCAL_NEUTRINO_PLUGINS)

NP_OBJDIR = $(BUILD_TMP)/neutrino-mp-plugins

ifeq ($(BOXARCH), sh4)
EXTRA_CPPFLAGS_MP_PLUGINS = -DMARTII
endif

$(D)/neutrino-mp-plugin.do_prepare:
	$(START_BUILD)
	rm -rf $(SOURCE_DIR)/plugins
	rm -rf $(SOURCE_DIR)/plugins.org
	set -e; if [ -d $(ARCHIVE)/plugins.git ]; \
		then cd $(ARCHIVE)/plugins.git; git pull; \
		else cd $(ARCHIVE); git clone https://github.com/fs-basis/plugins.git plugins.git; \
		fi
	cp -ra $(ARCHIVE)/plugins.git $(SOURCE_DIR)/plugins
	cp -ra $(SOURCE_DIR)/plugins $(SOURCE_DIR)/plugins.org
	@touch $@

$(D)/neutrino-mp-plugin.config.status: $(D)/bootstrap
	rm -rf $(NP_OBJDIR); \
	test -d $(NP_OBJDIR) || mkdir -p $(NP_OBJDIR); \
	cd $(NP_OBJDIR); \
		$(SOURCE_DIR)/plugins/autogen.sh $(SILENT_OPT) && automake --add-missing $(SILENT_OPT); \
		$(BUILDENV) \
		$(SOURCE_DIR)/plugins/configure $(SILENT_OPT) \
			--host=$(TARGET) \
			--build=$(BUILD) \
			--prefix= \
			--enable-silent-rules \
			--with-target=cdk \
			--include=/usr/include \
			--enable-maintainer-mode \
			--with-boxtype=$(BOXTYPE) \
			--with-plugindir=/var/tuxbox/plugins \
			--with-libdir=/usr/lib \
			--with-datadir=/usr/share/tuxbox \
			--with-fontdir=/usr/share/fonts \
			PKG_CONFIG=$(PKG_CONFIG) \
			PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
			CPPFLAGS="$(N_CPPFLAGS) $(EXTRA_CPPFLAGS_MP_PLUGINS) -DNEW_LIBCURL" \
			LDFLAGS="$(TARGET_LDFLAGS) -L$(NP_OBJDIR)/fx2/lib/.libs"
	@touch $@

$(D)/neutrino-mp-plugin.do_compile: $(D)/neutrino-mp-plugin.config.status
	$(MAKE) -C $(NP_OBJDIR) DESTDIR=$(TARGET_DIR)
	@touch $@

$(D)/neutrino-mp-plugin: $(D)/neutrino-mp-plugin.do_prepare $(D)/neutrino-mp-plugin.do_compile
	$(MAKE) -C $(NP_OBJDIR) install DESTDIR=$(TARGET_DIR)
	$(TOUCH)

neutrino-mp-plugin-clean:
	rm -f $(D)/neutrino-mp-plugins
	rm -f $(D)/neutrino-mp-plugin
	rm -f $(D)/neutrino-mp-plugin.config.status
	cd $(NP_OBJDIR); \
		$(MAKE) -C $(NP_OBJDIR) clean

neutrino-mp-plugin-distclean:
	rm -rf $(NP_OBJDIR)
	rm -f $(D)/neutrino-mp-plugin*

#
# mediathek
#
$(D)/mediathek:
	$(START_BUILD)
	$(REMOVE)/mediathek
	set -e; if [ -d $(ARCHIVE)/mediathek.git ]; \
		then cd $(ARCHIVE)/mediathek.git; git pull; \
		else cd $(ARCHIVE); git clone https://github.com/fs-basis/mediathek.git mediathek.git; \
		fi
	cp -ra $(ARCHIVE)/mediathek.git $(BUILD_TMP)/mediathek
	install -d $(TARGET_DIR)/var/tuxbox/plugins
	$(CHDIR)/mediathek; \
		cp -a plugins/* $(TARGET_DIR)/var/tuxbox/plugins/; \
#		cp -a share $(TARGET_DIR)/usr/
		rm -f $(TARGET_DIR)/var/tuxbox/plugins/neutrino-mediathek/livestream.lua
	$(REMOVE)/mediathek
	$(TOUCH)

#
# netzkino
#
$(D)/netzkino: $(D)/bootstrap
	$(START_BUILD)
	$(REMOVE)/netzkino
	set -e; if [ -d $(ARCHIVE)/netzkino.git ]; \
		then cd $(ARCHIVE)/netzkino.git; git pull; \
		else cd $(ARCHIVE); git clone https://github.com/fs-basis/netzkino.git netzkino.git; \
		fi
	cp -ra $(ARCHIVE)/netzkino.git $(BUILD_TMP)/netzkino
	$(CHDIR)/netzkino; \
		install -d $(TARGET_DIR)/var/tuxbox/plugins
		cp -R $(BUILD_TMP)/netzkino/* $(TARGET_DIR)/var/tuxbox/plugins/
	$(REMOVE)/netzkino
	$(TOUCH)
