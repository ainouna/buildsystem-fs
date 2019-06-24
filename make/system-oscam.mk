#
# makefile to build oscam
#
# -----------------------------------------------------------------------------

OSCAM_PATCH =

# -----------------------------------------------------------------------------

$(D)/oscam.do_prepare:
	$(START_BUILD)
	rm -rf $(SOURCE_DIR)/oscam
	rm -rf $(SOURCE_DIR)/oscam.org
	rm -rf $(LH_OBJDIR)
	test -d $(SOURCE_DIR) || mkdir -p $(SOURCE_DIR)
	[ -d "$(ARCHIVE)/oscam.git" ] && \
	(cd $(ARCHIVE)/oscam.git; git pull;); \
	[ -d "$(ARCHIVE)/oscam.git" ] || \
	git clone https://repo.or.cz/oscam.git $(ARCHIVE)/oscam.git; \
	cp -ra $(ARCHIVE)/oscam.git $(SOURCE_DIR)/oscam; \
	cp -ra $(SOURCE_DIR)/oscam $(SOURCE_DIR)/oscam.org
	set -e; cd $(SOURCE_DIR)/oscam; \
		$(call apply_patches, $(OSCAM_PATCH)); \
		 $(SHELL) ./config.sh --disable all \
		--enable WEBIF \
			CS_ANTICASC \
			CS_CACHEEX \
			CW_CYCLE_CHECK \
			CLOCKFIX \
			HAVE_DVBAPI \
			IRDETO_GUESSING \
			MODULE_MONITOR \
			READ_SDT_CHARSETS \
			TOUCH \
			WEBIF_JQUERY \
			WEBIF_LIVELOG \
			WITH_DEBUG \
			WITH_EMU \
			WITH_LB \
			WITH_NEUTRINO \
			\
			MODULE_CAMD35 \
			MODULE_CAMD35_TCP \
			MODULE_CCCAM \
			MODULE_CCCSHARE \
			MODULE_CONSTCW \
			MODULE_GBOX \
			MODULE_NEWCAMD \
			\
			READER_CONAX \
			READER_CRYPTOWORKS \
			READER_IRDETO \
			READER_NAGRA \
			READER_NAGRA_MERLIN \
			READER_SECA \
			READER_VIACCESS \
			READER_VIDEOGUARD \
			\
			CARDREADER_INTERNAL \
			CARDREADER_PHOENIX \
			CARDREADER_SMARGO \
			CARDREADER_SC8IN1
	@touch $@

$(D)/oscam.do_compile:
	cd $(SOURCE_DIR)/oscam; \
		$(BUILDENV) \
		$(MAKE) CROSS=$(TARGET)- USE_LIBCRYPTO=1 USE_LIBUSB=1 \
		PLUS_TARGET="-rezap" \
		CONF_DIR=/var/keys \
		EXTRA_LDFLAGS="$(TARGET_LDFLAGS)" \
		CC_OPTS=" -Os -pipe "
	@touch $@

$(D)/oscam: $(D)/bootstrap $(D)/openssl $(D)/libusb oscam.do_prepare oscam.do_compile
	rm -rf $(TARGET_DIR)/../OScam
	mkdir $(TARGET_DIR)/../OScam
	cp -pR $(SOURCE_DIR)/oscam/Distribution/* $(TARGET_DIR)/../OScam/
	$(REMOVE)/oscam
	$(TOUCH)

oscam-clean:
	rm -f $(D)/oscam
	rm -f $(D)/oscam.do_compile
	$(SOURCE_DIR)/oscam; \
		$(MAKE) distclean

# -----------------------------------------------------------------------------

oscam-distclean:
	rm -f $(D)/oscam*
