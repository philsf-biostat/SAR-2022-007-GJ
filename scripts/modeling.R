# setup -------------------------------------------------------------------
library(broom)

# raw estimate ------------------------------------------------------------
dv_chi <- svychisq(~dv + dsex, svy) %>% tidy
dv_chi_p <- dv_chi %>% pull(p.value)

iv_chi <- svychisq(~iv + dsex, svy) %>% tidy
iv_chi_p <- dv_chi %>% pull(p.value)

# adjusted ----------------------------------------------------------------

