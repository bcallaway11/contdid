# =============================================================================
# Title: Tests for sampling weights in cont_did()
# Description: weightsname is used by the dose estimators and both event
#   studies (#14): integer weights (including zeros) give the same estimates
#   as row-replicated data, results do not depend on the scale of the
#   weights, unit weights give the unweighted results, and the cck estimator
#   rejects weights.
# Author: Brant Callaway
# Last update: 2026-11-19
# Date created: 2026-11-19
# =============================================================================

weights_data <- function() {
  set.seed(1234)
  df <- simulate_contdid_data(n = 600, num_time_periods = 4, num_groups = 4,
                              dose_linear_effect = 1,
                              dose_quadratic_effect = 0.5)
  ids <- unique(df$id)
  set.seed(2)
  w <- sample(0:3, length(ids), replace = TRUE, prob = c(0.1, 0.3, 0.3, 0.3))
  df$w <- w[match(df$id, ids)]
  df
}

# each unit copied w times as new units (zero-weight units dropped)
replicate_units <- function(df) {
  r <- df[rep(seq_len(nrow(df)), df$w), ]
  copy <- stats::ave(r$time_period, r$id, r$time_period, FUN = seq_along)
  r$id <- as.integer(factor(paste(r$id, copy)))
  r
}

run_weights <- function(d, weightsname = NULL, target_parameter = "slope",
                        aggregation = "dose", dvals = NULL, seed = 1) {
  set.seed(seed)
  suppressWarnings(suppressMessages(cont_did(
    yname = "Y", tname = "time_period", idname = "id", dname = "D",
    gname = "G", data = d, target_parameter = target_parameter,
    aggregation = aggregation, weightsname = weightsname, dvals = dvals,
    degree = 3, num_knots = 0, biters = 100
  )))
}

test_that("integer weights give the same estimates as replicated units", {
  df <- weights_data()
  rep_df <- replicate_units(df)
  # dvals inside the dose range of the units with positive weight (the
  # default dvals and boundary knots come from all units' doses; with no
  # interior knots the cubic fit does not depend on the boundary knots)
  dv <- stats::quantile(df$D[df$D > 0 & df$w > 0], c(0.2, 0.5, 0.8))
  a <- run_weights(df, "w", dvals = dv)
  b <- run_weights(rep_df, dvals = dv)
  expect_equal(a$att.d, b$att.d)
  expect_equal(a$acrt.d, b$acrt.d)
  expect_equal(a$overall_att, b$overall_att)
  expect_equal(a$overall_acrt, b$overall_acrt)
  # the weights matter here
  expect_gt(max(abs(a$acrt.d - run_weights(df, dvals = dv)$acrt.d)), 0.05)

  for (tp in c("slope", "level")) {
    a <- run_weights(df, "w", tp, "eventstudy")
    b <- run_weights(rep_df, NULL, tp, "eventstudy")
    expect_equal(a$event_study$att.e, b$event_study$att.e, label = tp)
    expect_equal(a$overall_att$overall.att, b$overall_att$overall.att,
                 label = tp)
  }
})

test_that("results do not depend on the scale of the weights", {
  df <- weights_data()
  df$w_big <- df$w * 1000
  a <- run_weights(df, "w")
  b <- run_weights(df, "w_big")
  expect_equal(b$att.d, a$att.d)
  expect_equal(b$acrt.d, a$acrt.d)
  expect_equal(b$att.d_se, a$att.d_se)
  expect_equal(b$acrt.d_se, a$acrt.d_se)
  expect_equal(b$overall_att_se, a$overall_att_se)
  expect_equal(b$overall_acrt_se, a$overall_acrt_se)
  a <- run_weights(df, "w", "slope", "eventstudy")
  b <- run_weights(df, "w_big", "slope", "eventstudy")
  expect_equal(b$event_study$se.e, a$event_study$se.e)
  expect_equal(b$overall_att$overall.se, a$overall_att$overall.se)
})

test_that("unit weights give the unweighted results", {
  df <- weights_data()
  df$one <- 1
  a <- run_weights(df, "one")
  b <- run_weights(df)
  expect_equal(a$att.d, b$att.d)
  expect_equal(a$acrt.d_se, b$acrt.d_se)
  expect_equal(a$att.d_se, b$att.d_se)
  expect_equal(a$overall_acrt_se, b$overall_acrt_se)
})

test_that("the cck estimator rejects sampling weights", {
  df <- weights_data()
  df <- df[df$G %in% c(0, 2) & df$time_period %in% 1:2, ]
  expect_error(
    cont_did(yname = "Y", tname = "time_period", idname = "id", dname = "D",
             gname = "G", data = df, target_parameter = "slope",
             aggregation = "dose", dose_est_method = "cck",
             weightsname = "w"),
    "not supported with dose_est_method"
  )
})
