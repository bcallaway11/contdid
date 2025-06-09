#' @title Difference-in-differences with a Continuous Treatment
#'
#' @description A function for difference-in-differences with a continuous treatment in a
#'  staggered treatment adoption setting.
#'
#'  `cont_did` currently supports staggered treatment with continuous treatments using
#'  B-splines under the hood.
#'
#' @param dname The name of the treatment variable in the data.  The functionality of
#'  `cont_did` is different from the `did` package in that the treatment variable is
#'  the "amount" of the treatment in a particular period, rather than `gname` which
#'  gives the time period when a unit becomes treated.  The `dname` variable should,
#'  for a particular unit, be constant across time periods---even in pre-treatment periods.
#'  For units that never participate in the treatment, the amount of the treatment may
#'  not be defined in some applications---it is ignored in this function.
#' @inheritParams did::att_gt
#' @inheritParams ptetools::pte
#' @param xformula A formula for additional covariates.  This is not currently supported.
#' @param gname The name of the timing-group variable, i.e., when treatment starts for
#'  a particular unit.  The value of this variable should be set to be 0 for units that
#'  do not participate in the treatment in any time period.
#' @param target_parameter Two options are "level" and "slope".  In the first case, the function
#'  will report level effects, i.e., ATT's.  In the second case, the function will report
#'  slope effects, i.e., ACRT's
#' @param aggregation "dose" averages across timing-groups and time periods and provides results
#'  as a function of the dose.  "eventstudy" averages across timing-groups and doses and reports
#'  results as a function of the length of exposure to the treatment.
#'
#'  "none" is a stub for reporting fully disaggregated results that can be processed as desired
#'  by the user.  This is not currently supported though.
#'
#'  The combination of the arguments `target_parameter` and `aggregation` strongly affects the
#'  behavior of the function (and target of the analysis).  For example, setting
#'  `target_parameter="level"` and `aggregation="eventstudy"` is effectively the same thing
#'  as binarizing the treatment (i.e., where units are considered treated if they experience any
#'  positive amount of the treatment) and reporting an event study.
#'
#' @param treatment_type "continuous" or "discrete" depending on the nature of the treatment.
#'  Default is "continuous".  "discrete" is not yet supported.
#'
#' @param dose_est_method The method used to estimate the dose-specific effects.  The default
#'  is "parametric", where the user needs to specify the number of knots and degree for
#'  a B-spline which is assumed to be correctly specified.  The other option is "cck"
#'  which uses the a data-driven nonparametric method to estimate the dose-specific effects
#'  based on the `npiv` package and Chen, Christensen, and Kankanala (ReStud, 2025).
#'
#' @param dvals The values of the treatment at which to compute dose-specific effects.
#'  If it is not specified, the default choice will be use the percentiles of the dose among
#'  all ever-treated units.
#'
#' @param degree The degree of the B-Spline used in estimation.  The default is 3, which in
#'  combination with the default choice for the `num-knots`, leads to fitting models for
#'  the group of treated units that only that is a cubic polynomial in the dose.  Setting
#'  `degree=1` will lead to a linear model, while setting `degree=2` will lead to a quadratic model.
#'
#' @param num_knots The number of knots to include for the B-Spline.  The default is 0
#'  so that the spline is global (i.e., this will amount to fitting a global polynomial).
#' There is a bias-variance tradeoff for including more or less knots.
#'
#' @return cont_did_obj
#' 
#' @examples
#' # build small simulated data
#' set.seed(1234)
#' df <- simulate_contdid_data(
#'  n = 1000,
#'  num_time_periods = 4,
#'  num_groups = 4,
#'  dose_linear_effect = 0,
#'  dose_quadratic_effect = 0
#' )
#' 
#' # estimate effects of continuous treatment
#' cd_res <- cont_did(
#'  yname = "Y",
#'  tname = "time_period",
#'  idname = "id",
#'  dname = "D",
#'  data = df,
#'  gname = "G",
#'  target_parameter = "slope",
#'  aggregation = "dose",
#'  treatment_type = "continuous",
#'  control_group = "notyettreated",
#'  biters = 50,
#'  cband = TRUE,
#'  num_knots = 1,
#'  degree = 3,
#' )
#' 
#' summary(cd_res)
#' 
#' @export
cont_did <- function(yname,
                     dname,
                     gname = NULL,
                     tname,
                     idname,
                     xformula = ~1,
                     data,
                     target_parameter = c("level", "slope"),
                     aggregation = c("dose", "eventstudy", "none"),
                     treatment_type = c("continuous", "discrete"),
                     dose_est_method = c("parametric", "cck"),
                     dvals = NULL,
                     degree = 3,
                     num_knots = 0,
                     allow_unbalanced_panel = FALSE,
                     control_group = c("notyettreated", "nevertreated", "eventuallytreated"),
                     anticipation = 0,
                     weightsname = NULL,
                     alp = 0.05,
                     bstrap = TRUE,
                     cband = FALSE,
                     boot_type = "multiplier",
                     biters = 1000,
                     clustervars = NULL,
                     est_method = NULL,
                     base_period = "varying",
                     print_details = FALSE,
                     cl = 1,
                     ...) {
  # check argument formatting
  assert_data_frame(data)
  assert_names(c(yname, dname, idname), subset.of = colnames(data))
  if (xformula != ~1) stop("covariates not currently supported, please use xformula=~1")
  assert_choice(target_parameter, choices = c("level", "slope"))
  assert_choice(aggregation, choices = c("dose", "eventstudy", "none"))
  assert_choice(treatment_type, choices = c("continuous", "discrete"))
  if (aggregation == "none") stop("currently only support `dose` and `eventstudy` aggregations")
  if (allow_unbalanced_panel) stop("unbalanced panel not currently supported")
  assert_choice(control_group, choices = c("notyettreated", "nevertreated", "eventuallytreated"))
  if (anticipation != 0) warning("anticipation not tested yet, may not work")
  if (!is.null(weightsname)) warning("sampling weights not tested yet, may not work")
  assert_numeric(alp)
  if (!is.null(clustervars)) warning("two-way clustering not currently supported")
  if (!is.null(est_method)) stop("covariates not supported yet, set est_method=NULL")
  assert_choice(base_period, choices = c("varying", "universal"))
  dose_est_method <- dose_est_method[1]
  assert_choice(dose_est_method, choices = c("parametric", "cck"))

  # TODO: checks that dose is constant over time and that treatment is staggered
  # check for balanced panel data

  if (treatment_type == "discrete") {
    stop("discrete treatment not supported yet")
  }

  if (treatment_type == "continuous" && aggregation == "dose" && target_parameter == "slope") {
    attgt_fun <- cont_did_acrt
    gt_type <- "dose"
  }

  if (treatment_type == "continuous" && aggregation == "dose" && target_parameter == "level") {
    attgt_fun <- cont_did_acrt # it will compute both att and acrt
    gt_type <- "dose"
  }

  if (treatment_type == "continuous" && aggregation == "eventstudy" && target_parameter == "slope") {
    attgt_fun <- cont_did_acrt
    gt_type <- "att"
  }

  if (treatment_type == "continuous" && aggregation == "eventstudy" && target_parameter == "level") {
    attgt_fun <- ptetools::did_attgt
    gt_type <- "att"
  }

  # set up the timing group variable
  if (is.null(gname)) {
    data$.G <- BMisc::get_group(data, idname = idname, tname = tname, treatname = dname)
    gname <- ".G"
  }

  # cck estimator not supported with staggered adoption yet
  if (dose_est_method == "cck") {
    if (length(unique(data[[gname]])) != 2) {
      stop("cck estimator not supported with staggered adoption yet")
    }

    if (length(unique(data[[tname]])) != 2) {
      stop("cck estimator not supported with more than two time periods. consider averaging across pre and post treatment periods")
    }

    if (aggregation != "dose") {
      stop("event study not supported with cck estimator yet")
    }

    data <- BMisc::make_balanced_panel(data, idname, tname)
    data$.dy <- BMisc::get_first_difference(data, idname, yname, tname)
    maxT <- max(data[[tname]])
    post_data <- subset(data, data[[tname]] == maxT)
    dose <- post_data[[dname]]
    dy <- post_data$.dy
    m0 <- mean(dy[dose == 0])
    dy_centered <- dy - m0
    if (is.null(dvals)) {
      # choose dvals the same way as npiv::npiv
      # see line 733 https://github.com/JeffreyRacine/npiv/blob/main/R/npiv.R
      dvals <- seq(min(dose[dose > 0]),
        max(dose[dose > 0]),
        length.out = 50
      )
    }

    # just going to run code here
    cck_res <- npiv::npiv(
      Y = dy_centered[dose > 0],
      X = dose[dose > 0],
      W = dose[dose > 0],
      X.grid = dvals,
      knots = "quantile",
      boot.num = 999,
      J.x.degree = 3,
      K.w.degree = 3
    )

    att.d <- cck_res$h
    att.d_se <- cck_res$asy.se
    # back out implied uniform cband critical value from reported upper bound
    att.d_crit.val <- as.numeric((cck_res$h.upper - att.d) / att.d_se)[1]


    acrt.d <- cck_res$deriv
    acrt.d_se <- cck_res$deriv.asy.se
    # back out implied uniform cband critical value from reported upper bound
    acrt.d_crit.val <- as.numeric((cck_res$h.upper.deriv - acrt.d) / acrt.d_se)[1]

    if (!cband) {
      att.d_crit.val <- qnorm(1 - alp / 2)
      att.d_crit.val <- qnorm(1 - alp / 2)
    }

    # Compute average ACR
    average_acr <- mean(cck_res$deriv)

    # Get splines for dosage
    spline_dosage <- npiv::gsl.bs(cck_res$W[, drop = FALSE],
      degree = cck_res$K.w.degree,
      nbreak = (cck_res$K.w.segments + 1),
      knots = as.numeric(quantile(cck_res$W[, drop = FALSE],
        probs = seq(0, 1, length = (cck_res$K.w.segments + 1))
      )),
      deriv = 0,
      intercept = TRUE
    )
    # Sample size
    n_treated <- length(cck_res$Y)
    # compute influence function of spline beta
    infl_reg <- as.numeric(cck_res$Y - cck_res$h) *
      spline_dosage %*% (MASS::ginv(t(spline_dosage) %*% spline_dosage / n_treated))

    # Now, compute the average of the spline derivatives
    average_spline_deriv <- colMeans(npiv::gsl.bs(cck_res$W[, drop = FALSE],
      degree = cck_res$K.w.degree,
      nbreak = (cck_res$K.w.segments + 1),
      knots = as.numeric(quantile(cck_res$W[, drop = FALSE], probs = seq(0, 1, length = (cck_res$K.w.segments + 1)))),
      deriv = 1,
      intercept = TRUE
    ))
    # Now, put all terms together to get the influence function of the average ACR
    infl_avg_acr <- (cck_res$deriv - mean(cck_res$deriv)) + infl_reg %*% average_spline_deriv

    # Compute stanrd error
    se_avg_acr <- sd(infl_avg_acr) / sqrt(n_treated)

    ptep <- setup_pte_cont(
      yname = yname,
      gname = gname,
      tname = tname,
      dname = dname,
      idname = idname,
      data = data,
      target_parameter = target_parameter,
      aggregation = aggregation,
      treatment_type = treatment_type,
      dose_est_method = dose_est_method,
      cband = cband,
      alp = alp,
      boot_type = boot_type,
      gt_type = gt_type,
      weightsname = weightsname,
      biters = biters,
      cl = cl,
      call = call,
      ...
    )

    overall_att_res <- suppressWarnings(
      ptetools::pte_default(
        yname = ptep$yname,
        gname = ptep$gname,
        tname = ptep$tname,
        idname = ptep$idname,
        data = ptep$data,
        d_outcome = TRUE,
        anticipation = ptep$anticipation,
        base_period = ptep$base_period,
        control_group = ptep$control_group,
        weightsname = ptep$weightsname,
        biters = ptep$biters,
        alp = ptep$alp
      )
    )

    dose_order <- order(dose[dose > 0])
    dose_out <- dose[dose > 0][dose_order]
    att.d <- att.d[dose_order]
    att.d_se <- att.d_se[dose_order]
    acrt.d <- acrt.d[dose_order]
    acrt.d_se <- acrt.d_se[dose_order]

    out <- dose_obj(
      dose = dose_out,
      overall_att = overall_att_res$overall_att$overall.att,
      overall_att_se = overall_att_res$overall_att$overall.se,
      overall_att_inffunc = overall_att_res$overall_att$inf.func[[1]],
      overall_acrt = average_acr,
      overall_acrt_se = se_avg_acr,
      overall_acrt_inffunc = infl_avg_acr,
      att.d = att.d,
      att.d_se = att.d_se,
      att.d_crit.val = att.d_crit.val,
      att.d_inffunc = NULL,
      acrt.d = acrt.d,
      acrt.d_se = acrt.d_se,
      acrt.d_crit.val = acrt.d_crit.val,
      acrt.d_inffunc = NULL,
      pte_params = ptep
    )

    return(out)
  }

  res <- pte(
    yname = yname,
    gname = gname,
    tname = tname,
    idname = idname,
    data = data,
    setup_pte_fun = setup_pte_cont,
    subset_fun = cont_two_by_two_subset,
    attgt_fun = attgt_fun,
    xformla = xformula,
    target_parameter = target_parameter,
    aggregation = aggregation,
    treatment_type = treatment_type,
    dose_est_method = dose_est_method,
    anticipation = anticipation,
    dose_est_method = dose_est_method,
    gt_type = gt_type,
    cband = cband,
    alp = alp,
    boot_type = boot_type,
    biters = biters,
    cl = cl,
    dname = dname,
    degree = degree,
    num_knots = num_knots,
    dvals = dvals
  )

  res
}

#' @title Compute ACRT's for a Timing Group and Time Period
#'
#' @description This is the main function for computing dose-specific
#'  effects of a continuous treatment, given a particular timing group
#'  and time period.
#'
#' @inheritParams ptetools::pte_attgt
#' @inheritParams cont_did
#' @param knots A vector of placements of knots for b-splines.  Since this function
#'  is typically called internally, this would typically be set by the calling
#'  function.
#' @param ... additional arguments
#'
#' @return ptetools::attgt_if object
#' @export
cont_did_acrt <- function(
    gt_data,
    dvals = NULL,
    degree = 1,
    knots = numeric(0),
    ...) {
  gt_data$dy <- BMisc::get_first_difference(gt_data, "id", "Y", "period")
  # post_data <- subset(gt_data, name == "post")
  post_data <- with(gt_data, subset(gt_data, name == "post"))
  dose <- post_data$D
  dy <- post_data$dy

  dose_est_method <- list(...)$dose_est_method
  if (dose_est_method == "cck") {
    stop("cck estimator not supported with staggered adoption yet")
  }

  # if they were previously saved in shared_env, recover calculated knots
  if (!is.null(shared_env$knots)) {
    knots <- shared_env$knots
    dvals <- shared_env$dvals
  }

  bs <- splines2::bSpline(dose[dose > 0], degree = degree, knots = knots) |> as.data.frame()
  colnames(bs) <- paste0("bs_", colnames(bs))
  bs$dy <- dy[dose > 0]

  bs_reg <- lm(dy ~ ., data = bs)

  # dose_grid <- quantile(dose[dose > 0], probs = seq(0, 1, length.out = 100))
  bs_grid <- splines2::bSpline(dvals, degree = degree, knots = knots) |> as.data.frame()
  colnames(bs_grid) <- colnames(model.matrix(bs_reg))[-1]

  att.d <- predict(bs_reg, newdata = bs_grid) - mean(dy[dose == 0])

  # Compute derivative of B-spline basis
  bs_deriv <- splines2::dbs(dvals, degree = degree, knots = knots)

  # Compute derivative of E[Y|D]
  bs_reg_coef <- coef(bs_reg) # Coefficients from regression model
  acrt.d <- bs_deriv %*% bs_reg_coef[-1, drop = FALSE] # Exclude intercept term
  acrt.d <- as.numeric(acrt.d)

  # previous results just plug in different values of D
  # here average across the distribution of the dose to
  # get average treatment effect parameters
  bs_grid2 <- splines2::bSpline(dose[dose > 0], degree = degree, knots = knots) |> as.data.frame()
  colnames(bs_grid2) <- colnames(model.matrix(bs_reg))[-1]
  att.overall <- mean(predict(bs_reg, newdata = bs_grid2)) - mean(dy[dose == 0])
  bs_deriv2 <- splines2::dbs(dose[dose > 0], degree = degree, knots = knots)
  acrt.overall <- mean(bs_deriv2 %*% bs_reg_coef[-1, drop = FALSE])

  # capture components of influence function
  # for inference later
  Xe <- sandwich::estfun(bs_reg)
  bread <- sandwich::bread(bs_reg)
  # confirmed that this is the same as following
  # Xe <- sandwich::estfun(bs_reg)
  # n <- nrow(Xe)
  # M <- t(Xe) %*% Xe / n
  # X <- cbind(1, as.matrix(bs[, -ncol(bs)]))
  # B <- solve(t(X) %*% X / n)
  # Bread <- sandwich::bread(bs_reg) # note B==Bread
  # Meat <- sandwich::meat(bs_reg)
  # sandwich::vcovHC(bs_reg, type = "HC0")
  # sqrt(diag(solve(t(X) %*% X) %*% M %*% solve(t(X) %*% X))) / sqrt(n)
  # Bread %*% Meat %*% Bread
  # B %*% M %*% B

  # return influence function for ACRT^o, but also return components
  # to compute uniform confidence bands for ATT(d) and ACRT(d)
  # to be used outside this function

  # first component come from "knowing" the regression coefficients
  inffunc1 <- bs_deriv2 %*% bs_reg_coef[-1, drop = FALSE] - acrt.overall

  # second component comes from having estimated the regression coefficients
  inffunc2 <- Xe %*% bread %*% as.matrix(c(0, colMeans(bs_deriv2))) # augment with 0 for intercept spot

  # untreated don't contribute to influence function for ACRT
  inffunc <- rep(0, nrow(post_data))
  inffunc[dose > 0] <- as.numeric(inffunc1 + inffunc2)

  # some hack code to get influence function right
  # in aggregations into effects at different doses
  # just keep track of which unit are in the treated group
  # and comparison group for this g-t.  Set inffunc=1
  # for treated units and inffunc=Inf for comparison units.
  # args <- list(...)
  # if ("inffunc_track_treated_and_comparison" %in% names(args)) {
  #   if (args$inffunc_track_treated_and_comparison) {
  #     inffunc <- rep(Inf, nrow(post_data))
  #     inffunc[dose > 0] <- 1
  #   }
  # }

  attgt_if(
    attgt = acrt.overall,
    inf_func = inffunc,
    extra_gt_returns = list(
      att.d = att.d,
      acrt.d = acrt.d,
      att.overall = att.overall,
      acrt.overall = acrt.overall,
      bet = bs_reg_coef,
      bread = bread,
      Xe = Xe
    )
  )
}

#' @title Continuous Two-by-Two Subset
#'
#' @description A function for computing a 2x2 subset of original data.
#'  This function is adapted from `ptetools::two_by_two_subset` and allows
#'  for the treatment to be continuous.
#'  This is the subset with post treatment periods separately for the
#'  treated group and comparison group and pre-treatment periods in the period
#'  immediately before the treated group became treated.
#'
#' @param data the full dataset
#' @param g the current group
#' @param tp the current time period
#' @inheritParams ptetools::two_by_two_subset
#' @param control_group whether to use "notyettreated" (default) or
#'  "nevertreated"
#' @param ... extra arguments to get the subset correct
#'
#' @return list that contains correct subset of data, \code{n1}
#'  number of observations
#'  in this subset, and \code{disidx} a vector of the correct ids for this
#'  subset.
#'
#' @export
cont_two_by_two_subset <- function(data,
                                   g,
                                   tp,
                                   control_group = "notyettreated",
                                   anticipation = 0,
                                   base_period = "varying",
                                   ...) {
  # get the correct "base" period for this group
  main.base.period <- g - anticipation - 1

  #----------------------------------------------------
  if (base_period == "varying") {
    # if it's a pre-treatment time period (used for the
    # pre-test, we need to adjust the base period)

    # group not treated yet
    if (tp < (g - anticipation)) {
      # move to earlier period
      # not going to include anticipation here
      base.period <- tp - 1
    } else {
      # this is a post-treatment period
      base.period <- main.base.period
    }
  } else {
    base.period <- main.base.period
  }
  #----------------------------------------------------

  #----------------------------------------------------
  # collect the right subset of the data

  # get group g and not-yet-treated group
  if (control_group == "notyettreated") {
    this.data <- with(data, subset(data, G == g | G > tp | G == 0))
  } else {
    # use never treated group
    this.data <- with(data, subset(data, G == g | data$G == 0))
  }

  # get current period and base period data
  this.data <- with(this.data, subset(this.data, period == tp | period == base.period))

  # variable to keep track of pre/post periods
  this.data$name <- ifelse(this.data$period == tp, "post", "pre")

  # variable to indicate local treatment status
  this.data$D <- this.data$D * (this.data$G == g)

  # make this.data into gt_data_frame object
  this.data <- gt_data_frame(this.data)

  # number of observations used for this (g,t)
  n1 <- length(unique(this.data$id))
  disidx <- unique(data$id) %in% unique(this.data$id)

  list(gt_data = this.data, n1 = n1, disidx = disidx)
}
