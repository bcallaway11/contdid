# =============================================================================
# Title: Tests for cont_did
# Description: Smoke and recovery tests for cont_did() across target
#   parameters and aggregations, using simulate_contdid_data()
# Author: Brant Callaway
# Last update: 2026-10-29
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
