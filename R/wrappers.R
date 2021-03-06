# Wrapper functions
# Different shortcuts to doing traditional hypothesis tests & confidence
# intervals in R as well as calculating test statistics, following a pipe-able
# framework

#' Tidy t-test
#'
#' A tidier version of [t.test()][stats::t.test()] for two sample tests.
#'
#' @param x A data frame that can be coerced into a [tibble][tibble::tibble].
#' @param formula A formula with the response variable on the left and the
#'   explanatory on the right.
#' @param response The variable name in `x` that will serve as the response.
#'   This is alternative to using the `formula` argument.
#' @param explanatory The variable name in `x` that will serve as the
#'   explanatory variable.
#' @param order A string vector of specifying the order in which the levels of
#'   the explanatory variable should be ordered for subtraction, where `order =
#'   c("first", "second")` means `("first" - "second")`.
#' @param alternative Character string giving the direction of the alternative
#'   hypothesis. Options are `"two_sided"` (default), `"greater"`, or `"less"`.
#' @param mu A numeric value giving the hypothesized null mean value for a one
#'   sample test and the hypothesized difference for a two sample test.
#' @param conf_int A logical value for whether to include the confidence
#'   interval or not. `TRUE` by default.
#' @param conf_level A numeric value between 0 and 1. Default value is 0.95.
#' @param ... For passing in other arguments to [t.test()][stats::t.test()].
#'
#' @examples
#' # t test for comparing mpg against automatic/manual
#' mtcars %>%
#'   dplyr::mutate(am = factor(am)) %>%
#'   t_test(mpg ~ am, order = c("1", "0"), alternative = "less")
#'
#' @importFrom rlang f_lhs
#' @importFrom rlang f_rhs
#' @importFrom stats as.formula
#' @export
t_test <- function(x, formula, 
                   response = NULL, 
                   explanatory = NULL,
                   order = NULL,
                   alternative = "two_sided", 
                   mu = 0,
                   conf_int = TRUE,
                   conf_level = 0.95,
                   ...) {
  check_conf_level(conf_level)
  
  # convert all character and logical variables to be factor variables
  x <- tibble::as_tibble(x) %>%
    mutate_if(is.character, as.factor) %>%
    mutate_if(is.logical, as.factor)
  
  # parse response and explanatory variables
  response    <- enquo(response)
  explanatory <- enquo(explanatory)
  x <- parse_variables(x = x, formula = formula, 
                       response = response, explanatory = explanatory)
  
  # match with old "dot" syntax in t.test
  if (alternative == "two_sided") {
    alternative <- "two.sided"
  }
  
  # two sample
  if (has_explanatory(x)) {
    # if (!is.null(order)) {
    #   x[[as.character(attr(x, "explanatory"))]] <- factor(explanatory_variable(x), 
    #                                                       levels = c(order[1], 
    #                                                                  order[2]),
    #                                                       ordered = TRUE)
    # }
    check_order(x, explanatory_variable(x), order)
    prelim <- stats::t.test(formula = as.formula(paste0(attr(x, "response"),
                                                        " ~ ",
                                                        attr(x, "explanatory"))),
                            data = x,
                            alternative = alternative,
                            mu = mu,
                            conf.level = conf_level,
                            ...) %>%
      broom::glance()
  } else { # one sample
    prelim <- stats::t.test(response_variable(x),
                            alternative = alternative,
                            mu = mu,
                            conf.level = conf_level) %>%
      broom::glance()
  }
  
  if (conf_int) {
    results <- prelim %>%
      dplyr::select(
        statistic, t_df = parameter, p_value = p.value, alternative,
        lower_ci = conf.low, upper_ci = conf.high
      )
  } else {
    results <- prelim %>%
      dplyr::select(
        statistic, t_df = parameter, p_value = p.value, alternative
      )
  }
  
  results
}

#' Tidy t-test statistic
#'
#' A shortcut wrapper function to get the observed test statistic for a t test.
#'
#' @param x A data frame that can be coerced into a [tibble][tibble::tibble].
#' @param formula A formula with the response variable on the left and the
#'   explanatory on the right.
#' @param response The variable name in `x` that will serve as the response.
#'   This is alternative to using the `formula` argument.
#' @param explanatory The variable name in `x` that will serve as the
#'   explanatory variable.
#' @param order A string vector of specifying the order in which the levels of
#'   the explanatory variable should be ordered for subtraction, where `order =
#'   c("first", "second")` means `("first" - "second")`.
#' @param alternative Character string giving the direction of the alternative
#'   hypothesis. Options are `"two_sided"` (default), `"greater"`, or `"less"`.
#' @param mu A numeric value giving the hypothesized null mean value for a one
#'   sample test and the hypothesized difference for a two sample test.
#' @param conf_int A logical value for whether to include the confidence
#'   interval or not. `TRUE` by default.
#' @param conf_level A numeric value between 0 and 1. Default value is 0.95.
#' @param ... Pass in arguments to \\{infer\\} functions.
#'
#' @export
t_stat <- function(x, formula, 
                   response = NULL, 
                   explanatory = NULL,
                   order = NULL,
                   alternative = "two_sided", 
                   mu = 0,
                   conf_int = FALSE,
                   conf_level = 0.95,
                   ...) {
  check_conf_level(conf_level)
  
  # convert all character and logical variables to be factor variables
  x <- tibble::as_tibble(x) %>%
    mutate_if(is.character, as.factor) %>%
    mutate_if(is.logical, as.factor)
  
  # parse response and explanatory variables
  response    <- enquo(response)
  explanatory <- enquo(explanatory)
  x <- parse_variables(x = x, formula = formula, 
                       response = response, explanatory = explanatory)
  
  # match with old "dot" syntax in t.test
  if (alternative == "two_sided") {
    alternative <- "two.sided"
  }
  
  # two sample
  if (has_explanatory(x)) {
    # if (!is.null(order)) {
    #   x[[as.character(attr(x, "explanatory"))]] <- factor(explanatory_variable(x), 
    #                                                       levels = c(order[1], 
    #                                                                  order[2]),
    #                                                       ordered = TRUE)
    # }
    check_order(x, explanatory_variable(x), order)
    prelim <- stats::t.test(formula = as.formula(paste0(attr(x, "response"),
                                                        " ~ ",
                                                        attr(x, "explanatory"))),
                            data = x,
                            alternative = alternative,
                            mu = mu,
                            conf.level = conf_level,
                            ...) %>%
      broom::glance()
  } else { # one sample
    prelim <- stats::t.test(response_variable(x),
                            alternative = alternative,
                            mu = mu,
                            conf.level = conf_level) %>%
      broom::glance()
  }
  
  if (conf_int) {
    results <- prelim %>%
      dplyr::select(
        statistic, t_df = parameter, p_value = p.value, alternative,
        lower_ci = conf.low, upper_ci = conf.high
      )
  } else {
    results <- prelim %>%
      dplyr::select(
        statistic, t_df = parameter, p_value = p.value, alternative
      )
  }
  
  results %>%
    dplyr::select(statistic) %>%
    pull()
}

#' Tidy chi-squared test
#'
#' A tidier version of [chisq.test()][stats::chisq.test()] for goodness of fit
#' tests and tests of independence.
#'
#' @param x A data frame that can be coerced into a [tibble][tibble::tibble].
#' @param formula A formula with the response variable on the left and the
#'   explanatory on the right.
#' @param response The variable name in `x` that will serve as the response.
#'   This is alternative to using the `formula` argument.
#' @param explanatory The variable name in `x` that will serve as the
#'   explanatory variable.
#' @param ... Additional arguments for [chisq.test()][stats::chisq.test()].
#'
#' @examples
#' # chisq test for comparing number of cylinders against automatic/manual
#' mtcars %>%
#'   dplyr::mutate(cyl = factor(cyl), am = factor(am)) %>%
#'   chisq_test(cyl ~ am)
#'
#' @export
chisq_test <- function(x, formula, response = NULL, 
                       explanatory = NULL, ...) {
  # Parse response and explanatory variables
  response    <- enquo(response)
  explanatory <- enquo(explanatory)
  x <- parse_variables(x = x, formula = formula, 
                       response = response, explanatory = explanatory)
  
  if (!(class(response_variable(x)) %in% c("logical", "character", "factor"))) {
    stop_glue(
      'The response variable of `{attr(x, "response")}` is not appropriate\n',
      "since '{stat}' is expecting the response variable to be categorical."
    )
  }
  if (has_explanatory(x) && 
      !(class(response_variable(x)) %in% c("logical", "character", "factor"))) {
    stop_glue(
      'The explanatory variable of `{attr(x, "explanatory")}` is not appropriate\n',
      "since '{stat}' is expecting the explanatory variable to be categorical."
    )
  }
  
  x <- x %>%
    select(one_of(c(
      as.character((attr(x, "response"))), as.character(attr(x, "explanatory"))
    ))) %>%
    mutate_if(is.character, as.factor) %>%
    mutate_if(is.logical, as.factor)
  
  stats::chisq.test(table(x), ...) %>%
    broom::glance() %>%
    dplyr::select(statistic, chisq_df = parameter, p_value = p.value)
}

#' Tidy chi-squared test statistic
#'
#' A shortcut wrapper function to get the observed test statistic for a chisq
#' test. Uses [chisq.test()][stats::chisq.test()], which applies a continuity
#' correction.
#'
#' @param x A data frame that can be coerced into a [tibble][tibble::tibble].
#' @param formula A formula with the response variable on the left and the
#'   explanatory on the right.
#' @param response The variable name in `x` that will serve as the response.
#'   This is alternative to using the `formula` argument.
#' @param explanatory The variable name in `x` that will serve as the
#'   explanatory variable.
#' @param ... Additional arguments for [chisq.test()][stats::chisq.test()].
#'
#' @export
chisq_stat <- function(x, formula, response = NULL, 
                       explanatory = NULL, ...) {
  # Parse response and explanatory variables
  response    <- enquo(response)
  explanatory <- enquo(explanatory)
  x <- parse_variables(x = x, formula = formula, 
                       response = response, explanatory = explanatory)
  
  if (!(class(response_variable(x)) %in% c("logical", "character", "factor"))) {
    stop_glue(
      'The response variable of `{attr(x, "response")}` is not appropriate\n',
      "since '{stat}' is expecting the response variable to be categorical."
    )
  }
  if (has_explanatory(x) && 
      !(class(response_variable(x)) %in% c("logical", "character", "factor"))) {
    stop_glue(
      'The explanatory variable of `{attr(x, "explanatory")}` is not appropriate\n',
      "since '{stat}' is expecting the explanatory variable to be categorical."
    )
  }
  
  x <- x %>%
    select(one_of(c(
      as.character((attr(x, "response"))), as.character(attr(x, "explanatory"))
    ))) %>%
    mutate_if(is.character, as.factor) %>%
    mutate_if(is.logical, as.factor)
  
  suppressWarnings(stats::chisq.test(table(x), ...)) %>%
    broom::glance() %>%
    dplyr::select(statistic) %>%
    pull()
}

check_conf_level <- function(conf_level) {
  if (
    (class(conf_level) != "numeric") | (conf_level < 0) | (conf_level > 1)
  ) {
    stop_glue("The `conf_level` argument must be a number between 0 and 1.")
  }
}
