#
# patch helper
#
neutrino%-patch \
libstb-hal%-patch:
	( cd $(SOURCE_DIR) && diff -Nur --exclude-from=$(SCRIPTS_DIR)/diff-exclude $(subst -patch,,$@).org $(subst -patch,,$@) > $(BASE_DIR)/$(subst -patch,.patch,$@) ; [ $$? -eq 1 ] )

# keeping all patches together in one file
# uncomment if needed
#
# Neutrino MP DDT
NEUTRINO_MP_DDT_PATCHES =
NEUTRINO_MP_LIBSTB_DDT_PATCHES =

#Neutrino MP FS
NEUTRINO_MP_FS_PATCHES =
LIBSTB_HAL_FS_PATCHES =
#
NEUTRINO_MP_FS_LCD4L_PATCHES =
#
NEUTRINO_MP_FS_TEST_PATCHES =
#
