#' @title Simulate data for DiD with a Continuous Treatment
#'
#' @description A function that simulates panel data when there
#'  is a continuous treatment.
#'
#'  Besides the parameters that can be passed to the function, some
#'  values are hard coded.  The individual fixed effect is drawn from a
#'  normal distribution with mean equal to the group.  The time effects
#'  are hard coded to be equal to the time period.  The dose
#'  is drawn from a uniform distribution between 0 and 1.
#'
#' @param n The number of cross-sectional units.  Default is 5000.
#' @param num_time_periods The number of time periods.  Default is 4.
#' @param num_groups The number of groups.  Default is the number of time periods.
#'  In this case, the groups will consist of a never-treated group and groups
#'  that become treated in every period starting in the second period.
#' @param pg A vector of probabilities that a unit will be in a particular treated group.
#'  The default is equal probabilities.
#' @param pu The probability that a unit will be in the never-treated group.  The
#'  default is that it is 1/num_groups.
#' @param dose_linear_effect The linear effect of the treatment.  Default is 0.
#' @param dose_quadratic_effect The quadratic effect of the treatment.  Default is 0.
#'
#' @return A balanced panel data frame with the following columns:
#' - id: unit id
#' - time_period: time period
#' - Y: outcome
#' - G: unit's group
#' - D: amount of the treatment
#'
#' @export
simulate_contdid_data <- function(
    n = 5000,
    num_time_periods = 4,
    num_groups = num_time_periods,
    pg = rep(1 / num_groups, num_groups - 1),
    pu = 1 / (num_groups),
    dose_linear_effect = 0,
    dose_quadratic_effect = 0) {
    # tidyr needs to be available for this function to work
    if (!requireNamespace("tidyr", quietly = TRUE)) {
        stop("Package 'tidyr' is required for this function but is not installed.
         Please install it with install.packages('tidyr').", call. = FALSE)
    }

    # create time periods
    time_periods <- 1:num_time_periods

    # assign units to groups
    groups <- c(0, time_periods[-1])
    p <- c(pu, pg)
    G <- sample(groups, n, replace = TRUE, prob = p)

    # create dose variable
    D <- runif(n, 0, 1)

    # draw individual fixed effect
    # values are hard coded
    eta <- rnorm(n, mean = G)

    # time effects
    # values are hard coded
    time_effects <- 1:num_time_periods

    # generate untreated potential outcomes
    Y0t <- sapply(1:num_time_periods, function(tp) {
        time_effects[tp] + eta + rnorm(n)
    })

    # generate treated potential outcomes
    Y1t <- sapply(1:num_time_periods, function(tp) {
        dose_linear_effect * D + dose_quadratic_effect * D^2 + time_effects[tp] + eta + rnorm(n)
    })

    # matrix to decide which outcomes to keep
    post_mat <- sapply(1:num_time_periods, function(tp) {
        1 * ((G <= tp) & G != 0)
    })

    # generate observed outcomes
    Y <- post_mat * Y1t + (1 - post_mat) * Y0t

    # create cross-sectional data from
    df <- as.data.frame(Y)
    colnames(df) <- paste0("Y_", 1:num_time_periods)
    df$id <- 1:n
    df$G <- G
    df$D <- D

    # convert to long format
    df2 <- tidyr::pivot_longer(df,
        cols = tidyr::starts_with("Y"),
        names_to = "time_period",
        names_prefix = "Y_",
        names_transform = list(time_period = as.numeric),
        values_to = "Y"
    ) |> as.data.frame()

    df2
}
