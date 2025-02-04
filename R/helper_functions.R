#' @title Choose Knots at Quantiles
#'
#' @description A function to choose knots for fitting b-splines by the quantile of x
#'
#' @param x vector of treatment doses
#' @param num_knots the number of knots to use
#'
#' @return a vector containing the locations of the knots
#'
#' @export
choose_knots_quantile <- function(x, num_knots) {
    quantile(x, probs = seq(0, 1, length.out = num_knots + 2))[-c(1, num_knots + 2)]
}

#' @title Choose Evenly Spaced Knots
#'
#' @description A function to place equally spaced knots for fitting b-splines
#'
#' @inheritParams choose_knots_quantile
#'
#' @return a vector containing the locations of the knots
#'
#' @export
choose_knots_even <- function(x, num_knots) {
    seq(min(x), max(x), length.out = num_knots + 2)[-c(1, num_knots + 2)]
}
