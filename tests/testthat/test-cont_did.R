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

# control_group and base_period were not passed on to ptetools::pte(), so
# the defaults (not-yet-treated, varying) were always used (#19, #10).
test_that("control_group and base_period are used", {
  set.seed(11)
  n <- 1500
  n_periods <- 6
  grp <- sample(c(0, 3, 5), n, replace = TRUE, prob = c(0.4, 0.3, 0.3))
  dose <- ifelse(grp > 0, runif(n, 1, 10), 0)
  a <- rnorm(n)
  df <- do.call(rbind, lapply(seq_len(n_periods), function(t) {
    data.frame(id = seq_len(n), period = t, G = grp, D = dose,
               Y = a + 0.1 * t + ifelse(grp == 5, 0.15, 0) * t +
                 ifelse(grp > 0 & t >= grp, 0.05 * dose, 0) +
                 rnorm(n, sd = 0.1))
  }))
  fit <- function(control_group, base_period, aggregation = "dose") {
    suppressWarnings(cont_did(
      yname = "Y", tname = "period", idname = "id", dname = "D", gname = "G",
      data = df, target_parameter = "level", aggregation = aggregation,
      treatment_type = "continuous", control_group = control_group,
      base_period = base_period, biters = 20, cband = FALSE, degree = 3
    ))
  }
  # overall ATT by hand: ATT(g,t) = mean change of group g minus mean change
  # of the comparison group, from base period g - 1; averaged over post
  # periods within group, then across groups by size
  change <- function(t, b) {
    w <- reshape(df[df$period %in% c(t, b), c("id", "period", "Y")],
                 idvar = "id", timevar = "period", direction = "wide")
    w[[paste0("Y.", t)]] - w[[paste0("Y.", b)]]
  }
  hand <- function(in_control) {
    att_g <- sapply(c(3, 5), function(g) {
      mean(sapply(g:n_periods, function(t) {
        dy <- change(t, g - 1)
        mean(dy[grp == g]) - mean(dy[in_control(t)])
      }))
    })
    weighted.mean(att_g, c(sum(grp == 3), sum(grp == 5)))
  }
  expect_equal(fit("nevertreated", "universal")$overall_att,
               hand(function(t) grp == 0))
  expect_equal(fit("notyettreated", "universal")$overall_att,
               hand(function(t) grp == 0 | grp > t))
  # a universal base period normalizes event time -1 to 0 (#10)
  es <- fit("nevertreated", "universal", "eventstudy")$event_study
  expect_equal(es$att.egt[es$egt == -1], 0)
  es_varying <- fit("nevertreated", "varying", "eventstudy")$event_study
  expect_false(isTRUE(all.equal(es$att.egt, es_varying$att.egt)))
})

# clustervars is passed on to ptetools (ptetools #6); it used to be ignored
# with a warning.
test_that("clustervars clusters the standard errors", {
  set.seed(3)
  n_cl <- 40
  per_cl <- 15
  n <- n_cl * per_cl
  n_periods <- 4
  cl <- rep(seq_len(n_cl), each = per_cl)
  g_cl <- sample(c(0, 3, 4), n_cl, replace = TRUE)
  dose <- ifelse(g_cl[cl] > 0, runif(n, 1, 5), 0)
  d <- expand.grid(id = seq_len(n), period = seq_len(n_periods))
  d$cl <- cl[d$id]
  d$G <- g_cl[d$cl]
  d$D <- dose[d$id]
  shock <- matrix(rnorm(n_cl * n_periods), n_cl)
  d$Y <- rnorm(n)[d$id] + shock[cbind(d$cl, d$period)] +
    (d$G > 0 & d$period >= d$G) * 0.5 * d$D + rnorm(nrow(d))
  run <- function(...) {
    suppressWarnings(cont_did(
      yname = "Y", tname = "period", idname = "id", dname = "D", gname = "G",
      data = d, target_parameter = "level", aggregation = "eventstudy",
      treatment_type = "continuous", control_group = "notyettreated",
      bstrap = FALSE, ...
    ))
  }
  unclustered <- run()
  expect_equal(run(clustervars = "id")$event_study$se.egt,
               unclustered$event_study$se.egt)
  clustered <- run(clustervars = "cl")
  expect_equal(clustered$event_study$att.egt, unclustered$event_study$att.egt)
  # cluster-by-period shocks: clustering raises the standard errors
  expect_gt(clustered$overall_att$overall.se,
            1.5 * unclustered$overall_att$overall.se)
  expect_error(
    cont_did(yname = "Y", tname = "period", idname = "id", dname = "D",
             gname = "G", data = d, target_parameter = "level",
             aggregation = "dose", treatment_type = "continuous",
             control_group = "notyettreated", dose_est_method = "cck",
             clustervars = "cl"),
    "not supported with dose_est_method"
  )
})

# One treated cohort with a linear dose response: ACRT(e = 0) is the slope of
# the outcome change on the dose among the treated units.
linear_dose_data <- function(n = 4000, p_treat = 0.2) {
  set.seed(2)
  treated <- rbinom(n, 1, p_treat)
  dose <- ifelse(treated == 1, runif(n, 1, 5), 0)
  df <- expand.grid(id = seq_len(n), period = 1:4)
  df$G <- ifelse(treated[df$id] == 1, 3, 0)
  df$D <- dose[df$id]
  df$Y <- rnorm(n)[df$id] + 0.1 * df$period + df$D * (df$period >= 3) + rnorm(nrow(df))
  df
}

test_that("the ACRT influence function gives the robust standard error of the dose slope", {
  df <- linear_dose_data()
  n <- length(unique(df$id))
  res <- suppressWarnings(cont_did(
    yname = "Y", dname = "D", gname = "G", tname = "period", idname = "id", data = df,
    target_parameter = "slope", aggregation = "eventstudy", degree = 1,
    treatment_type = "continuous", control_group = "nevertreated",
    dose_est_method = "parametric", biters = 100
  ))
  pre <- df[df$period == 2 & df$G > 0, ]
  post <- df[df$period == 3 & df$G > 0, ]
  fit <- lm(post$Y - pre$Y ~ post$D)
  i0 <- which(res$event_study$egt == 0)
  expect_equal(res$event_study$att.egt[i0], unname(coef(fit)[2]), tolerance = 1e-8)
  inf_func <- res$event_study$inf.function$dynamic.inf.func.e[, i0]
  se_hc0 <- sqrt(sandwich::vcovHC(fit, type = "HC0")[2, 2])
  expect_equal(sqrt(sum(inf_func^2)) / n, se_hc0, tolerance = 1e-8)
})

# The choice arguments' defaults list every option and were not resolved
# with match.arg(), so cont_did() failed when they were left at their
# defaults (#12).
test_that("cont_did() runs with default choice arguments", {
  set.seed(1)
  df <- simulate_contdid_data(
    n = 500, num_time_periods = 4, num_groups = 4,
    dose_linear_effect = 0.5, dose_quadratic_effect = 0
  )
  res <- suppressWarnings(cont_did(
    yname = "Y", tname = "time_period", idname = "id", dname = "D",
    gname = "G", data = df, biters = 20
  ))
  # defaults: level effects, aggregated by dose
  expect_true(is.finite(res$overall_att))
  expect_error(
    cont_did(yname = "Y", tname = "time_period", idname = "id", dname = "D",
             gname = "G", data = df, aggregation = "nope"),
    "should be one of"
  )
})
