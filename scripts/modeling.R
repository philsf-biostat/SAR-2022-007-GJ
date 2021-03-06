# setup -------------------------------------------------------------------
library(broom)
library(epitools)

# pretty format of OR + CI
format_or <- function(or, digits = 2) {
  paste0(
    "OR: ",
    format.float(or[1], digits),
    ", ",
    "95% CI: ",
    format.interval(or[2:3], digits),
    ", ",
    style_pvalue(or[4], digits = digits+1, prepend_p = TRUE)
  )
}

# associations with sex ---------------------------------------------------

dv_chi <- svychisq(~dv + dsex, svy, statistic = "Chisq") %>% tidy
dv_chi_p <- dv_chi %>% pull(p.value)

iv_chi <- svychisq(~iv + dsex, svy, statistic = "Chisq") %>% tidy
iv_chi_p <- iv_chi %>% pull(p.value)

# per sex analysis --------------------------------------------------------

svy_m <- svydesign(ids = ~1,
                   data = analytical %>% filter(dsex == "Male"),
                   weights = ~postwt)
svy_f <- svydesign(ids = ~1,
                   data = analytical %>% filter(dsex == "Female"),
                   weights = ~postwt)

dv_m <- svychisq(~iv2 + dv2, svy_m, statistic = "Chisq") %>% tidy
dv_m_p <- dv_m %>% pull(p.value)

dv_f <- svychisq(~iv2 + dv2, svy_f, statistic = "Chisq") %>% tidy
dv_f_p <- dv_f %>% pull(p.value)

cmh <- svytable(~iv2 + dv2 + dsex, svy) %>% mantelhaen.test() %>% tidy
cmh_p <- cmh %>% pull(p.value)

# OR ----------------------------------------------------------------------

or_o <- svytable(~ iv2 + dv2, svy) %>% oddsratio() %>% suppressWarnings()
or_o <- c(or_o$measure[2, ], or_o$p.value[2, "chi.square"]) %>% as.numeric()
or_m <- svytable(~ iv2 + dv2, svy_m) %>% oddsratio() %>% suppressWarnings()
or_m <- c(or_m$measure[2, ], or_m$p.value[2, "chi.square"]) %>% as.numeric()
or_f <- svytable(~ iv2 + dv2, svy_f) %>% oddsratio() %>% suppressWarnings()
or_f <- c(or_f$measure[2, ], or_f$p.value[2, "chi.square"]) %>% as.numeric()
or_cmh <- cmh[c("estimate", "conf.low", "conf.high", "p.value")] %>% as.numeric()

# difference between crude and adjusted
or_diff_o_adj <- all.equal(or_cmh[1], or_o[1]) %>% parse_number()
# difference between men and women
or_diff_sex_adj <- all.equal(or_f[1], or_m[1]) %>% parse_number()

# unweighted analysis -----------------------------------------------------

or_o_un <- analytical %>%
  filter() %>%
  select(iv2, dv2) %>%
  table() %>%
  oddsratio()
or_o_un <- c(or_o_un$measure[2, ], or_o_un$p.value[2, "chi.square"]) %>% as.numeric()

or_m_un <- analytical %>%
  filter(dsex == "Male") %>%
  select(iv2, dv2) %>%
  table() %>%
  oddsratio()
or_m_un <- c(or_m_un$measure[2, ], or_m_un$p.value[2, "chi.square"]) %>% as.numeric()

or_f_un <- analytical %>%
  filter(dsex == "Female") %>%
  select(iv2, dv2) %>%
  table() %>%
  oddsratio()
or_f_un <- c(or_f_un$measure[2, ], or_f_un$p.value[2, "chi.square"]) %>% as.numeric()

cmh_un <- analytical %>%
  select(iv2, dv2, dsex) %>%
  table() %>%
  mantelhaen.test() %>%
  suppressWarnings() %>%
  tidy()
cmh_p_un <- cmh_un %>% pull(p.value)
or_cmh_un <- cmh_un[c("estimate", "conf.low", "conf.high", "p.value")] %>% as.numeric()

# difference between crude and adjusted
or_diff_o_adj_un <- all.equal(or_cmh_un[1], or_o_un[1]) %>% parse_number()
# difference between men and women
or_diff_sex_adj_un <- all.equal(or_f_un[1], or_m_un[1]) %>% parse_number()
