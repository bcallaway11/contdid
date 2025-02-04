library(BMisc)
library(did)

test_that("test basic functionality", {
  # Simulate data
  set.seed(123)
  # baseline simulation parameters
  sp <- did::reset.sim()
  # adjust some default simulation parameters
  sp$n <- 10000 # increase number of units
  sp$bett <- sp$betu <- sp$te.bet.X <- rep(0, length(sp$bett)) # no effects of covariates
  sp$te <- 0 # the effect of the treatment is 0
  df <- did::build_sim_dataset(sp)
  n <- length(unique(df$id))
  D <- runif(n, 0, 1)
  # add treatment variable, it is fully independent of everything else
  df$D <- BMisc::time_invariant_to_panel(D, df, "id")

  cd_res <- suppressWarnings(
    cont_did(
      yname = "Y",
      tname = "period",
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
  expect_true(abs(out$overall_acrt) < 0.1)

  cd_res_es_level <- suppressWarnings(
    cont_did(
      yname = "Y",
      tname = "period",
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
      tname = "period",
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

  expect_true(abs(out$overall_att$overall_att) < 0.1)
  expect_true(abs(out$event_study$Estimate[5]) < 0.1) # event study at e=2
})
