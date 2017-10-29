#
# diff helper
#
%-patch:
	( cd $(SOURCE_DIR) && diff -Nur --exclude-from=$(SCRIPTS_DIR)/diff-exclude $(subst -patch,,$@).org $(subst -patch,,$@) > $(BASE_DIR)/$(subst -patch,.patch,$@) ; [ $$? -eq 1 ] )

# keeping all patches together in one file
# uncomment if needed
#

# LIB-STB-Hal for MP CST Next / NI from github
NEUTRINO_MP_LIBSTB_CST_NEXT_PATCHES +=

# Neutrino MP CST Next from github
NEUTRINO_MP_CST_NEXT_PATCHES +=

# Neutrino MP CST Next NI from github
NEUTRINO_MP_CST_NEXT_NI_PATCHES +=

# Neutrino MP Tango
NEUTRINO_MP_TANGOS_PATCHES +=

# Neutrino HD2
NEUTRINO_HD2_PATCHES +=
NEUTRINO_HD2_PLUGINS_PATCHES +=

#FS Libstb Hal
LIBSTB_HAL_PATCHES +=

# FS Neutrino Alpha
FS_NEUTRINO_ALPHA_PATCHES +=

# FS Neutrino Test (Master)
FS_NEUTRINO_TEST_PATCHES +=

# FS Neutrino-Current
FS_NEUTRINO_CURRENT_PATCHES +=

# Neutrino-Matze
NEUTRINO_MATZE_PATCHES +=
