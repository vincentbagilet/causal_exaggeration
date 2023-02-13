# library(tidyverse)
# library(mediocrethemes)
# library(AER)
# 
set_mediocre_all()

n <- 10000
n_iter <- 200
res <- rep(NA, n_iter)
alpha_y <- 1
alpha_x <- 1
delta <- 1
beta <- 1
gamma <- 0.1

for (i in 1:n_iter) {
  z <- rnorm(n, 0, 1)
  u <- rnorm(n, 0, 1)
  e_x <- rnorm(n, 0, 1)
  e_y <- rnorm(n, 0, 1)
  x <- alpha_x + gamma*z + delta*u + e_x
  y <- alpha_y + beta*x + delta*u + e_y

  data_iv_homo <- tibble(x, y, z, u, e_x, e_y)
  
  # res[i] <- lm(y ~ x) %>% 
  #   coef() %>% 
  #   .[["x"]]/beta
  
  res[i] <- ivreg(y ~ x | z) %>%
    coef() %>%
    .[["x"]]/beta
}

res %>%
  qplot() +
  geom_vline(aes(xintercept = mean(res))) +
  geom_vline(aes(xintercept = 1), linetype = "dashed")

mean(res) - 1



