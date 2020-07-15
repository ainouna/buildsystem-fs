#
# patch helper
#
neutrino%-patch \
libstb-hal%-patch:
	( cd $(SOURCE_DIR) && diff -Nur --exclude-from=$(SCRIPTS_DIR)/diff-exclude $(subst -patch,,$@).org $(subst -patch,,$@) > $(BASE_DIR)/$(subst -patch,.patch,$@) ; [ $$? -eq 1 ] )

# keeping all patches together in one file
# uncomment if needed
#
# Neutrino DDT
NEUTRINO_DDT_PATCHES =
NEUTRINO_LIBSTB_DDT_PATCHES =

#Neutrino FS
NEUTRINO_FS_PATCHES =
LIBSTB_HAL_FS_PATCHES =
#
NEUTRINO_FS_LCD4L_PATCHES =
#
NEUTRINO_FS_TEST_PATCHES =

# Oscam patch
OSCAM_LOCAL_PATCH =
