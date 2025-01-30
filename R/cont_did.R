#' @title cont_did
#'
#' @description A function for difference-in-differences with a continuous treatment in a
#'  staggered treatment adoption setting.
#'
#'  `cont_did` currently supports staggered treatment with continuous treatments using the
#'  `np` package (=> kernel regression) under the hood.
#'
#' @param dname The name of the treatment variable in the data.  The functionality of
#'  `cont_did` is different from the `did` package in that the treatment variable is
#'  the "amount" of the treatment in a particular period, rather than `gname` which
#'  gives the time period when a unit becomes treated.  Based on the `dname` variable,
#'  the `cont_did` package will "figure out" the treatment timing.
#'
#'  To give an example, suppose that the treatment variable is called `D` in data frame
#'  `df`.  Furthermore, suppose there are 4 time periods, and a particular unit becomes
#'  treated in the time period 3 with dose 5.  Then, `dname="D"`, and for this unit
#'  `df$D` will be `c(0, 0, 5, 5)`.`
#' @inheritParams did::att_gt
#' @param gname This is an optional name for the timing-group.  If it is not supplied, then
#'  the function will attempt to create a timing-group variable based on the `dname`.
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
#' @return cont_did_obj
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
                     dvals = NULL,
                     degree = 1,
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
    attgt_fun <- cont_did_att
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

  res <- pte2(
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
    anticipation = anticipation,
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

cont_did_acrt <- function(
    gt_data,
    dvals = NULL,
    degree = 1,
    knots = numeric(0),
    ...) {
  gt_data$dy <- BMisc::get_first_difference(gt_data, "id", "Y", "period")
  post_data <- subset(gt_data, name == "post")
  dose <- post_data$D
  dy <- post_data$dy

  # if they were previously saved in shared_env, recover calculated knots
  if (!is.null(shared_env$knots)) {
    knots <- shared_env$knots
    dvals <- shared_env$dvals
  }

  bs <- splines2::bSpline(dose[dose > 0], degree = degree, knots = knots) %>% as.data.frame()
  colnames(bs) <- paste0("bs_", colnames(bs))
  bs$dy <- dy[dose > 0]

  bs_reg <- lm(dy ~ ., data = bs)

  # dose_grid <- quantile(dose[dose > 0], probs = seq(0, 1, length.out = 100))
  bs_grid <- splines2::bSpline(dvals, degree = degree, knots = knots) %>% as.data.frame()
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
  bs_grid2 <- splines2::bSpline(dose[dose > 0], degree = degree, knots = knots) %>% as.data.frame()
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

#' @title cont_two_by_two_subset
#'
#' @description A function for computing a 2x2 subset of original data.
#'  This function is adapted from `pte::two_by_two_subset` and allows
#'  for the treatment to be continuous.
#'  This is the subset with post treatment periods separately for the
#'  treated group and comparison group and pre-treatment periods in the period
#'  immediately before the treated group became treated.
#'
#' @param data the full dataset
#' @param g the current group
#' @param tp the current time period
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
    this.data <- subset(data, G == g | G > tp | G == 0)
  } else {
    # use never treated group
    this.data <- subset(data, G == g | G == 0)
  }

  # get current period and base period data
  this.data <- subset(this.data, period == tp | period == base.period)

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
