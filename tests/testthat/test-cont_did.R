# =============================================================================
# Title: Tests for cont_did
# Description: Smoke and recovery tests for cont_did() across target
#   parameters and aggregations, using simulate_contdid_data()
# Author: Brant Callaway
# Last update: 2026-11-19
# Date created: 2025-02-04
# =============================================================================

test_that("test basic functionality", {
  # Simulate data
  set.seed(1234)
  df <- simulate_contdid_data(
    n = 5000,
    num_time_periods = 4,
    num_groups = 4,
    dose_linear_effect = 0,
    dose_quadratic_effect = 0
  )
  cd_res <- suppressWarnings(
    cont_did(
      yname = "Y",
      tname = "time_period",
      idname = "id",
      dname = "D",
      data = df,
      gname = "G",
      target_parameter = "slope",
      aggregation = "dose",
      treatment_type = "continuous",
      control_group = "notyettreated",
      biters = 100,
      cband = TRUE,
      num_knots = 1,
      degree = 3,
    )
  )

  out <- summary(cd_res)
  ggcont_did(cd_res, type = "att")
  ggcont_did(cd_res, type = "acrt")

  expect_true(abs(out$overall_att) < 0.5)
  expect_true(abs(out$overall_acrt) < 0.2)

  cd_res_es_level <- suppressWarnings(
    cont_did(
      yname = "Y",
      tname = "time_period",
      idname = "id",
      dname = "D",
      data = df,
      gname = "G",
      target_parameter = "level",
      aggregation = "eventstudy",
      treatment_type = "continuous",
      control_group = "notyettreated",
      biters = 100,
      cband = TRUE,
      num_knots = 1,
      degree = 3,
    )
  )

  out <- summary(cd_res_es_level)
  ggcont_did(cd_res_es_level)

  expect_true(abs(out$overall_att$overall_att) < 0.5)
  expect_true(abs(out$event_study$Estimate[5]) < 0.5) # event study at e=2

  cd_res_es_slope <- suppressWarnings(
    cont_did(
      yname = "Y",
      tname = "time_period",
      idname = "id",
      dname = "D",
      data = df,
      gname = "G",
      target_parameter = "slope",
      aggregation = "eventstudy",
      treatment_type = "continuous",
      control_group = "notyettreated",
      biters = 100,
      cband = TRUE,
      num_knots = 1,
      degree = 3,
    )
  )

  out <- summary(cd_res_es_slope)
  ggcont_did(cd_res_es_slope)

  expect_true(abs(out$overall_att$overall_att) < 0.2)
  expect_true(abs(out$event_study$Estimate[4]) < 0.2) # event study at e=1
})


test_that("changing variable names is ok", {
  # this tests a previous bug where the dose had to be called "D"

  # Simulate data
  set.seed(1234)
  df <- simulate_contdid_data(
    n = 1000,
    num_time_periods = 4,
    num_groups = 4,
    dose_linear_effect = 0,
    dose_quadratic_effect = 0
  )
  names(df) <- c("unit_id", "the_group", "the_dose", "which_time", "outcome")
  expect_silent({
    suppressWarnings(
      cont_did(
        yname = "outcome",
        tname = "which_time",
        idname = "unit_id",
        dname = "the_dose",
        data = df,
        gname = "the_group",
        target_parameter = "slope",
        aggregation = "dose",
        treatment_type = "continuous",
        control_group = "notyettreated",
        biters = 50,
        cband = TRUE,
        num_knots = 1,
        degree = 3,
      )
    )
  })
})

test_that("level event study recovers a nonzero ATT", {
  # with Y1 - Y0 = dose_linear_effect * D and D ~ U(0, 1), ATT(g,t) = 0.5
  # in every post-treatment period; a null effect would not detect
  # a mis-specified treatment indicator being passed to DRDID
  set.seed(1234)
  df <- simulate_contdid_data(
    n = 5000,
    num_time_periods = 4,
    num_groups = 4,
    dose_linear_effect = 1,
    dose_quadratic_effect = 0
  )
  cd_res <- suppressWarnings(
    cont_did(
      yname = "Y",
      tname = "time_period",
      idname = "id",
      dname = "D",
      data = df,
      gname = "G",
      target_parameter = "level",
      aggregation = "eventstudy",
      treatment_type = "continuous",
      control_group = "notyettreated",
      biters = 100,
      cband = TRUE,
      num_knots = 1,
      degree = 3
    )
  )

  out <- summary(cd_res)
  es <- out$event_study

  expect_true(abs(out$overall_att$overall_att - 0.5) < 0.15)
  expect_true(all(abs(es$Estimate[es$`Event Time` >= 0] - 0.5) < 0.2))
  expect_true(all(abs(es$Estimate[es$`Event Time` < 0]) < 0.2))
})

# Two periods, one timing group: the dose regression is a single lm() on the
# treated units, so ATT(d) can be computed by hand.
two_period_dose_data <- function(n = 2000) {
  set.seed(1)
  G <- sample(c(0, 2), n, replace = TRUE, prob = c(0.4, 0.6))
  D <- ifelse(G == 2, runif(n), 0)
  dy <- 1 + (G == 2) * 2 * D^2 + rnorm(n)
  data.frame(
    id = rep(seq_len(n), each = 2), time_period = rep(1:2, n),
    G = rep(G, each = 2), D = rep(D, each = 2), Y = as.numeric(rbind(0, dy))
  )
}

test_that("ATT(d) is evaluated with the basis the dose regression was fitted with", {
  df <- two_period_dose_data()
  res <- suppressWarnings(cont_did(
    yname = "Y", tname = "time_period", idname = "id", dname = "D", gname = "G",
    data = df, target_parameter = "level", aggregation = "dose",
    treatment_type = "continuous", control_group = "nevertreated",
    degree = 3, num_knots = 0, biters = 50
  ))
  post <- df[df$time_period == 2, ]
  treated <- post[post$G == 2, ]
  # a cubic B-spline without interior knots spans the cubic polynomials
  fit <- lm(Y ~ poly(D, 3, raw = TRUE), data = treated)
  expected <- predict(fit, newdata = data.frame(D = res$dose)) - mean(post$Y[post$G == 0])
  expect_equal(as.numeric(res$att.d), as.numeric(expected), tolerance = 1e-8)
})

# Year-coded groups and periods with a group column named G: ptetools
# recodes groups and periods to 1..T internally, and before ptetools #13
# that overwrote a user column named G, giving NaN estimates.
test_that("a group column named G with year-coded data gives the same results", {
  set.seed(1234)
  df <- simulate_contdid_data(
    n = 1000, num_time_periods = 4, num_groups = 4,
    dose_linear_effect = 0.5, dose_quadratic_effect = 0
  )
  df$year <- df$time_period + 2000
  df$grp <- ifelse(df$G == 0, 0, df$G + 2000)
  run <- function(gname) {
    d <- df
    d[[gname]] <- df$grp
    set.seed(7)
    res <- suppressWarnings(cont_did(
      yname = "Y", tname = "year", idname = "id", dname = "D",
      gname = gname, data = d, target_parameter = "level",
      aggregation = "eventstudy", treatment_type = "continuous",
      control_group = "notyettreated", biters = 50
    ))
    c(res$overall_att$overall.att, res$event_study$att.egt)
  }
  expected <- run("grp")
  expect_true(all(is.finite(expected)))
  expect_equal(run("G"), expected)
})

# With anticipation and unequally spaced periods, the level event study must
# match ptetools::pte_default() (the same cells, base periods and comparison
# groups as did::att_gt()). setup_pte_cont() previously did not pass
# anticipation on to ptetools::setup_pte().
test_that("anticipation matches pte_default() with unequally spaced periods", {
  set.seed(1234)
  yrs <- c(2001, 2003, 2006, 2010)
  df <- simulate_contdid_data(
    n = 1000, num_time_periods = 4, num_groups = 4,
    dose_linear_effect = 0.5, dose_quadratic_effect = 0
  )
  df$year <- yrs[df$time_period]
  df$grp <- ifelse(df$G == 0, 0, yrs[pmax(df$G, 1)])
  for (ant in c(0, 2)) {
    res <- suppressWarnings(cont_did(
      yname = "Y", tname = "year", idname = "id", dname = "D", gname = "grp",
      data = df, target_parameter = "level", aggregation = "eventstudy",
      treatment_type = "continuous", control_group = "notyettreated",
      anticipation = ant, biters = 0
    ))
    expected <- suppressWarnings(ptetools::pte_default(
      yname = "Y", gname = "grp", tname = "year", idname = "id", data = df,
      d_outcome = TRUE, est_method = "dr", anticipation = ant, biters = 0
    ))
    expect_equal(res$event_study$egt, expected$event_study$egt)
    expect_equal(res$event_study$att.egt, expected$event_study$att.egt)
  }
})

# A cohort with no more treated units than dose-regression parameters gave
# "something off with overall influence function" or "non-conformable
# arguments" (ptetools #17); now the error says which cohort and why.
test_that("a cohort too small for the dose regression gives a clear error", {
  set.seed(1)
  n <- 300
  yrs <- c(2001, 2003, 2005, 2007)
  grp <- c(rep(2005, 2), rep(2007, 120), rep(0, n - 122))
  dose <- ifelse(grp > 0, runif(n, 1, 5), 0)
  d <- data.frame(id = rep(seq_len(n), each = 4), year = rep(yrs, n),
                  G = rep(grp, each = 4), D = rep(dose, each = 4))
  d$Y <- rnorm(nrow(d))
  expect_error(
    suppressWarnings(cont_did(
      yname = "Y", tname = "year", idname = "id", dname = "D", gname = "G",
      data = d, target_parameter = "slope", aggregation = "dose",
      treatment_type = "continuous", control_group = "notyettreated",
      degree = 1, biters = 20
    )),
    "group 2005.*2 treated unit\\(s\\) but 2 parameters"
  )
})
