#packages and set cores
library(tidyverse)
library(broom)
library(furrr)

##Here, I try to build a simple Venn diagram for the maths section, 
#just considering fixed variances (equal to 1) and varying the correlation between x and w (gamma)

future::plan(multisession, workers = availableCores() - 1)

#set baseline parameters
baseline_param <- tibble(
  N = 500,
  beta = 0.1,
  gamma = 0.9,
  delta = 0.05
)

#function to generate data
generate_data <- function(N, beta, gamma, delta) {
  
  data <- tibble(id = 1:N) |>
    mutate(
      w = rnorm(N, 0, 1),
      epsilon = rnorm(N, 0, sqrt(1 - gamma^2)),
      x = gamma*w + epsilon,
      u = rnorm(N, 0, sqrt(1 - beta^2 - delta^2 - 2*beta*delta*gamma)),
      y = beta*x + delta*w + u
    )
}

#function to run the estimation
run_estim <- function(data) {
  short_reg <- lm(data = data, y ~ x) |>
    broom::tidy() |>
    filter(term == "x") |> 
    mutate(type_reg = "short")
  
  long_reg <- lm(data = data, y ~ x + w) |>
    broom::tidy() |>
    filter(term == "x") |> 
    mutate(type_reg = "long")
  
  rbind(long_reg, short_reg) |> 
    mutate(
      var_y = var(data$y), 
      var_x = var(data$x), 
      var_w = var(data$w), 
      cov_yw = cov(data$y, data$w), 
      cov_yx = cov(data$y, data$x), 
      cov_xw = cov(data$x, data$w)
    )
}

#function to compute a simulation
compute_sim <- function(...) {
  generate_data(...) |> 
    run_estim() |> 
    cbind(as_tibble(list(...))) #add parameters used for generation
}

#replicate the process
#set the number of iterations and parameters to vary
n_iter <- 100
vect_gamma <- c(0.1, 0.6)
#define the complete set of parameters
param <- baseline_param |>
  crossing(rep_id = 1:n_iter)  |>
  select(-gamma) |>
  crossing(gamma = vect_gamma) |>
  select(-rep_id)

result_sim <- future_pmap_dfr(param, compute_sim,
                              .options = furrr_options(seed = TRUE)) |> 
  as_tibble() |> 
  rename(se = std.error, p_value = p.value) |>
  select(-term, -statistic)

test_data <- pmap_dfr(baseline_param, generate_data)

result_summary <- result_sim |>  
  mutate(significant = (p_value <= 0.05)) |> 
  group_by(type_reg, gamma) |> 
  mutate(
    exagg = mean(ifelse(significant, estimate/baseline_param$beta, NA), na.rm = TRUE)
  ) |>
  select(exagg, everything(), -significant) |> 
  summarise(across(.fns = mean)) 

result_summary

R_x_w <- lm(data = test_data, x ~ w)
# R_yx_w <- test_data |> 
  # mutate(y_perp_x <- )
  
  # lm(data = test_data, residuals(lm(data = test_data, y ~ x)) ~ w)




