
<!-- README.md is generated from README.Rmd. Please edit that file -->

# contdid

<!-- badges: start -->
<!-- badges: end -->

An R package for difference-in-differences with a continuous treatment.

## Installation

You can install the development version of contdid from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("bcallaway11/contdid")

library(contdid)
```

## Example

To start with, we will simulate some data, where the continuous
treatment `D` has no affect on the outcome.

``` r
# Simulate data
set.seed(123)
sp <- did::reset.sim()
sp$n <- 10000
df <- did::build_sim_dataset(sp)
n <- length(unique(df$id))
D <- runif(n, 0, 1)
# add treatment variable
df$D <- BMisc::time_invariant_to_panel(D, df, "id")
```

The following code illustrates how to estimate `ATT(d)` and `ACRT(d)`
using the `cont_did` function, provided by the package.

The interface is basically the same as for the `did` package and for
other packages that rely on the `ptetools` backend. The main additional
things that need to be provided to the function are the name of the
continuous treatment variable, which should be passed through the
`dname` argument.

The `cont_did` function expects the continuous treatment variable to
behave in certain ways:

1.  It needs to be time-invariant.

2.  It should be set to its time-invariant value in pre-treatment
    periods. This is just a convention of the package, but, in
    particular, you should not have the treatment variable coded as
    being 0 in pre-treatment periods.

3.  For units that don’t participate in the treatment in any time
    period, the treatment variable just needs to be time-invariant. In
    some applications, e.g., the continuous treatment variable may be
    defined for units that don’t actually participate in the treatment.
    In other applications, it may not be defined for units that do not
    participate in the treatment. The function behaves the same way in
    either case.

Next, the other important parameters are `target_parameter`,
`aggregation`, and `treatment_type`:

- `target_parameter` can either be “level” or “slope”. If “level”, then
  the function will calculate `ATT` parameters. If set to be “slope”,
  then the function will calculate `ACRT` parameters—these are causal
  response parameters that are derivatives of the `ATT` parameters. Our
  paper @callaway-goodman-santanna-2024 points out some complications
  for interpreting these derivative type parameters under the most
  commonly invoked version of the parallel trends assumption.

- `aggregation` can either by “eventstudy” or “dose”. For “eventstudy”,
  depending on the value of the `target_parameter` argument, the
  function will provide either the average `ATT` across different event
  times or the average `ACRT` across different event times. For “dose”,
  the function will average across all time periods and report average
  affects across different values of the continuous treatment. For the
  “dose” aggregation, results are calculated for both `ATT` and `ACRT`
  and can be displayed by providing different arguments to plotting
  functions (see example below).

- `treatment_type` can either be “continuous” or “discrete”. Currently
  only “continuous” is supported. In this case, the code proceeds as if
  the treatment really is continuous. The estimate are computed
  nonparametrically using B-splines. The user can control the number of
  knots and the degree of the B-splines using the `num_knots` and
  `degree` arguments. The defaults are `num_knots=0` and `degree=1`
  which amounts to estimating `ATT(d)` by estimating a linear model in
  the continuous treatment among treated units and subtracting the
  average outcome among the comparison units.

### Dose Aggregation

``` r
cd_res <- cont_did(
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

summary(cd_res)
#> ATT(d):
#>    dose ATT(d) Std. Error [95% Simult.  Conf. Band]  
#>  0.0966 1.2933     0.1205        0.9557      1.6308 *
#>  0.1080 1.3225     0.1029        1.0341      1.6108 *
#>  0.1172 1.3439     0.0883        1.0964      1.5913 *
#>  0.1281 1.3669     0.0762        1.1536      1.5803 *
#>  0.1401 1.3891     0.0696        1.1943      1.5840 *
#>  0.1501 1.4052     0.0639        1.2262      1.5843 *
#>  0.1598 1.4192     0.0504        1.2781      1.5603 *
#>  0.1706 1.4324     0.0571        1.2724      1.5925 *
#>  0.1812 1.4433     0.0514        1.2995      1.5872 *
#>  0.1898 1.4509     0.0569        1.2915      1.6102 *
#>  0.1993 1.4577     0.0594        1.2913      1.6241 *
#>  0.2084 1.4629     0.0627        1.2873      1.6385 *
#>  0.2186 1.4672     0.0640        1.2878      1.6466 *
#>  0.2282 1.4700     0.0636        1.2918      1.6483 *
#>  0.2402 1.4718     0.0671        1.2839      1.6597 *
#>  0.2525 1.4718     0.0680        1.2813      1.6624 *
#>  0.2636 1.4704     0.0659        1.2857      1.6551 *
#>  0.2745 1.4678     0.0651        1.2854      1.6501 *
#>  0.2859 1.4638     0.0647        1.2826      1.6451 *
#>  0.2986 1.4582     0.0637        1.2797      1.6367 *
#>  0.3087 1.4529     0.0594        1.2867      1.6192 *
#>  0.3189 1.4470     0.0570        1.2873      1.6067 *
#>  0.3296 1.4401     0.0587        1.2757      1.6044 *
#>  0.3393 1.4334     0.0583        1.2702      1.5966 *
#>  0.3488 1.4266     0.0545        1.2740      1.5792 *
#>  0.3586 1.4192     0.0510        1.2763      1.5622 *
#>  0.3677 1.4123     0.0499        1.2726      1.5519 *
#>  0.3778 1.4044     0.0510        1.2617      1.5472 *
#>  0.3898 1.3951     0.0471        1.2632      1.5270 *
#>  0.4000 1.3873     0.0452        1.2606      1.5140 *
#>  0.4104 1.3795     0.0445        1.2548      1.5041 *
#>  0.4207 1.3720     0.0366        1.2694      1.4746 *
#>  0.4308 1.3651     0.0385        1.2572      1.4729 *
#>  0.4425 1.3576     0.0427        1.2379      1.4774 *
#>  0.4528 1.3516     0.0454        1.2245      1.4788 *
#>  0.4627 1.3465     0.0469        1.2151      1.4779 *
#>  0.4711 1.3427     0.0471        1.2108      1.4746 *
#>  0.4812 1.3389     0.0482        1.2040      1.4738 *
#>  0.4930 1.3356     0.0507        1.1937      1.4775 *
#>  0.5031 1.3338     0.0535        1.1840      1.4837 *
#>  0.5128 1.3332     0.0524        1.1865      1.4799 *
#>  0.5228 1.3336     0.0511        1.1905      1.4766 *
#>  0.5325 1.3350     0.0511        1.1919      1.4781 *
#>  0.5436 1.3378     0.0506        1.1961      1.4795 *
#>  0.5530 1.3411     0.0529        1.1928      1.4894 *
#>  0.5666 1.3470     0.0554        1.1919      1.5021 *
#>  0.5759 1.3519     0.0571        1.1920      1.5119 *
#>  0.5852 1.3574     0.0557        1.2014      1.5134 *
#>  0.5946 1.3635     0.0552        1.2090      1.5180 *
#>  0.6039 1.3700     0.0535        1.2200      1.5199 *
#>  0.6130 1.3767     0.0528        1.2289      1.5245 *
#>  0.6215 1.3832     0.0542        1.2312      1.5351 *
#>  0.6310 1.3908     0.0548        1.2373      1.5443 *
#>  0.6410 1.3990     0.0496        1.2600      1.5380 *
#>  0.6534 1.4094     0.0439        1.2865      1.5323 *
#>  0.6620 1.4167     0.0403        1.3038      1.5295 *
#>  0.6727 1.4258     0.0403        1.3128      1.5388 *
#>  0.6816 1.4332     0.0409        1.3187      1.5477 *
#>  0.6911 1.4411     0.0416        1.3246      1.5575 *
#>  0.7032 1.4508     0.0445        1.3261      1.5754 *
#>  0.7120 1.4576     0.0450        1.3315      1.5837 *
#>  0.7207 1.4640     0.0481        1.3292      1.5988 *
#>  0.7304 1.4708     0.0488        1.3339      1.6076 *
#>  0.7385 1.4760     0.0512        1.3326      1.6194 *
#>  0.7482 1.4819     0.0524        1.3350      1.6287 *
#>  0.7577 1.4869     0.0546        1.3340      1.6398 *
#>  0.7684 1.4919     0.0558        1.3355      1.6482 *
#>  0.7775 1.4953     0.0573        1.3347      1.6560 *
#>  0.7878 1.4984     0.0584        1.3347      1.6620 *
#>  0.7976 1.5003     0.0590        1.3350      1.6657 *
#>  0.8086 1.5013     0.0578        1.3394      1.6632 *
#>  0.8182 1.5011     0.0571        1.3410      1.6612 *
#>  0.8280 1.4997     0.0544        1.3473      1.6521 *
#>  0.8369 1.4974     0.0544        1.3452      1.6497 *
#>  0.8465 1.4937     0.0567        1.3350      1.6525 *
#>  0.8568 1.4883     0.0571        1.3283      1.6484 *
#>  0.8655 1.4826     0.0576        1.3212      1.6440 *
#>  0.8745 1.4754     0.0536        1.3251      1.6256 *
#>  0.8847 1.4656     0.0541        1.3140      1.6172 *
#>  0.8920 1.4574     0.0535        1.3077      1.6072 *
#>  0.9016 1.4453     0.0581        1.2826      1.6081 *
#>  0.9114 1.4313     0.0621        1.2572      1.6054 *
#>  0.9218 1.4143     0.0644        1.2340      1.5946 *
#>  0.9313 1.3971     0.0693        1.2029      1.5912 *
#>  0.9417 1.3758     0.0724        1.1730      1.5787 *
#>  0.9509 1.3553     0.0776        1.1380      1.5726 *
#>  0.9608 1.3311     0.0881        1.0842      1.5780 *
#>  0.9716 1.3020     0.1073        1.0013      1.6027 *
#>  0.9822 1.2706     0.1140        0.9513      1.5898 *
#>  0.9909 1.2430     0.1215        0.9026      1.5834 *
#> 
#> 
#> ACRT(d):
#>    dose ACRT(d) Std. Error [95% Simult.  Conf. Band] 
#>  0.0966  2.7132     1.6341       -2.3387      7.7651 
#>  0.1080  2.4394     1.5059       -2.2161      7.0948 
#>  0.1172  2.2263     1.4313       -2.1984      6.6510 
#>  0.1281  1.9807     1.3087       -2.0650      6.0263 
#>  0.1401  1.7245     1.2233       -2.0574      5.5063 
#>  0.1501  1.5219     1.1387       -1.9985      5.0422 
#>  0.1598  1.3305     1.0573       -1.9381      4.5990 
#>  0.1706  1.1292     0.9455       -1.7938      4.0522 
#>  0.1812  0.9422     0.8194       -1.5909      3.4753 
#>  0.1898  0.7956     0.7281       -1.4554      3.0465 
#>  0.1993  0.6422     0.6085       -1.2390      2.5235 
#>  0.2084  0.5038     0.5778       -1.2823      2.2899 
#>  0.2186  0.3562     0.5613       -1.3790      2.0914 
#>  0.2282  0.2248     0.4756       -1.2455      1.6951 
#>  0.2402  0.0723     0.4205       -1.2277      1.3724 
#>  0.2525 -0.0697     0.3889       -1.2720      1.1326 
#>  0.2636 -0.1881     0.3496       -1.2688      0.8925 
#>  0.2745 -0.2928     0.2564       -1.0854      0.4999 
#>  0.2859 -0.3923     0.2876       -1.2813      0.4967 
#>  0.2986 -0.4889     0.3300       -1.5090      0.5312 
#>  0.3087 -0.5563     0.3651       -1.6851      0.5725 
#>  0.3189 -0.6149     0.3924       -1.8281      0.5983 
#>  0.3296 -0.6672     0.4031       -1.9135      0.5791 
#>  0.3393 -0.7058     0.4261       -2.0230      0.6115 
#>  0.3488 -0.7353     0.4401       -2.0959      0.6253 
#>  0.3586 -0.7581     0.4689       -2.2075      0.6914 
#>  0.3677 -0.7714     0.4916       -2.2913      0.7484 
#>  0.3778 -0.7780     0.5074       -2.3466      0.7907 
#>  0.3898 -0.7742     0.4973       -2.3115      0.7632 
#>  0.4000 -0.7612     0.5077       -2.3308      0.8085 
#>  0.4104 -0.7385     0.5056       -2.3015      0.8244 
#>  0.4207 -0.7070     0.4960       -2.2404      0.8264 
#>  0.4308 -0.6668     0.4786       -2.1462      0.8126 
#>  0.4425 -0.6097     0.4476       -1.9933      0.7740 
#>  0.4528 -0.5492     0.4171       -1.8387      0.7404 
#>  0.4627 -0.4827     0.3886       -1.6839      0.7185 
#>  0.4711 -0.4190     0.3779       -1.5872      0.7492 
#>  0.4812 -0.3352     0.3434       -1.3968      0.7264 
#>  0.4930 -0.2255     0.3244       -1.2285      0.7775 
#>  0.5031 -0.1220     0.3072       -1.0717      0.8278 
#>  0.5128 -0.0144     0.2813       -0.8841      0.8553 
#>  0.5228  0.0972     0.2595       -0.7051      0.8996 
#>  0.5325  0.1976     0.2529       -0.5841      0.9794 
#>  0.5436  0.3040     0.2624       -0.5071      1.1150 
#>  0.5530  0.3868     0.2587       -0.4129      1.1864 
#>  0.5666  0.4939     0.2509       -0.2818      1.2697 
#>  0.5759  0.5592     0.2592       -0.2421      1.3605 
#>  0.5852  0.6181     0.2856       -0.2649      1.5010 
#>  0.5946  0.6708     0.2788       -0.1911      1.5328 
#>  0.6039  0.7162     0.2997       -0.2102      1.6426 
#>  0.6130  0.7542     0.3177       -0.2278      1.7362 
#>  0.6215  0.7836     0.3145       -0.1885      1.7558 
#>  0.6310  0.8104     0.3331       -0.2193      1.8401 
#>  0.6410  0.8309     0.3465       -0.2403      1.9021 
#>  0.6534  0.8456     0.3555       -0.2535      1.9446 
#>  0.6620  0.8489     0.3555       -0.2501      1.9478 
#>  0.6727  0.8450     0.3551       -0.2526      1.9426 
#>  0.6816  0.8352     0.3615       -0.2825      1.9529 
#>  0.6911  0.8179     0.3611       -0.2984      1.9341 
#>  0.7032  0.7859     0.3634       -0.3375      1.9093 
#>  0.7120  0.7555     0.3575       -0.3498      1.8608 
#>  0.7207  0.7196     0.3545       -0.3764      1.8155 
#>  0.7304  0.6727     0.3535       -0.4202      1.7657 
#>  0.7385  0.6281     0.3485       -0.4494      1.7056 
#>  0.7482  0.5676     0.3387       -0.4795      1.6147 
#>  0.7577  0.5020     0.3299       -0.5180      1.5220 
#>  0.7684  0.4195     0.3198       -0.5693      1.4083 
#>  0.7775  0.3424     0.2996       -0.5839      1.2687 
#>  0.7878  0.2476     0.2811       -0.6213      1.1165 
#>  0.7976  0.1496     0.2552       -0.6392      0.9384 
#>  0.8086  0.0310     0.2526       -0.7499      0.8119 
#>  0.8182 -0.0810     0.2491       -0.8511      0.6892 
#>  0.8280 -0.2018     0.2580       -0.9995      0.5959 
#>  0.8369 -0.3172     0.3020       -1.2507      0.6164 
#>  0.8465 -0.4497     0.3634       -1.5731      0.6736 
#>  0.8568 -0.5998     0.4085       -1.8627      0.6631 
#>  0.8655 -0.7313     0.4533       -2.1326      0.6699 
#>  0.8745 -0.8745     0.4861       -2.3772      0.6282 
#>  0.8847 -1.0448     0.5430       -2.7235      0.6339 
#>  0.8920 -1.1722     0.5907       -2.9983      0.6538 
#>  0.9016 -1.3451     0.6333       -3.3029      0.6126 
#>  0.9114 -1.5286     0.6930       -3.6709      0.6137 
#>  0.9218 -1.7320     0.7499       -4.0502      0.5862 
#>  0.9313 -1.9234     0.7992       -4.3941      0.5473 
#>  0.9417 -2.1430     0.8456       -4.7573      0.4712 
#>  0.9509 -2.3427     0.8799       -5.0628      0.3775 
#>  0.9608 -2.5651     0.9339       -5.4523      0.3220 
#>  0.9716 -2.8171     1.0198       -5.9697      0.3356 
#>  0.9822 -3.0750     1.0922       -6.4516      0.3016 
#>  0.9909 -3.2903     1.1526       -6.8535      0.2729 
#> ---
#> Signif. codes: `*' confidence band does not cover 0
ggcont_did(cd_res, type = "att")
```

<img src="man/figures/README-unnamed-chunk-5-1.png" width="100%" />

``` r
ggcont_did(cd_res, type = "acrt")
```

<img src="man/figures/README-unnamed-chunk-5-2.png" width="100%" />

### Event Study Aggregations

An event study aggregation for `ATT`

``` r
cd_res_es_level <- cont_did(
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

summary(cd_res_es_level)
#> 
#> Overall ATT:  
#>     ATT    Std. Error     [ 95%  Conf. Int.]  
#>  1.0171        0.0336     0.9513       1.083 *
#> 
#> 
#> Dynamic Effects:
#>  Event Time Estimate Std. Error  [95%  Conf. Band]  
#>          -2   0.1651     0.0419 0.0516      0.2785 *
#>          -1   0.2665     0.0327 0.1777      0.3552 *
#>           0   0.9330     0.0299 0.8519      1.0141 *
#>           1   1.0211     0.0427 0.9055      1.1367 *
#>           2   1.1971     0.0859 0.9644      1.4298 *
#> ---
#> Signif. codes: `*' confidence band does not cover 0
ggcont_did(cd_res_es_level)
```

<img src="man/figures/README-unnamed-chunk-6-1.png" width="100%" />

And an event study aggregation for `ACRT`

``` r
cd_res_es_slope <- cont_did(
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

summary(cd_res_es_slope)
#> 
#> Overall ACRT:  
#>      ATT    Std. Error     [ 95%  Conf. Int.] 
#>  -0.0582        0.0619    -0.1794      0.0631 
#> 
#> 
#> Dynamic Effects:
#>  Event Time Estimate Std. Error   [95%  Conf. Band] 
#>          -2   0.0943     0.0895 -0.1433      0.3319 
#>          -1   0.0234     0.0648 -0.1485      0.1953 
#>           0   0.0435     0.0538 -0.0994      0.1864 
#>           1  -0.1086     0.1095 -0.3991      0.1819 
#>           2  -0.4764     0.2681 -1.1880      0.2352 
#> ---
#> Signif. codes: `*' confidence band does not cover 0
ggcont_did(cd_res_es_slope)
```

<img src="man/figures/README-unnamed-chunk-7-1.png" width="100%" />
