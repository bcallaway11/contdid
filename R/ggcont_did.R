#' @title ggcont_did
#' 
#' @param dose_obj a result from running `cont_did`
#' @param type whether to plot ATT(d) or ACRT(d), defaults to `att` for
#'  plotting ATT(d).  For ACRT(d), use "acrt"
#' @description a function to plot results with a continuous treatment
ggcont_did <- function(dose_obj, type="att") {
    # just call native plotting from `ptetools` package, no adjustments needed
    ggpte_cont(dose_obj, type)
}