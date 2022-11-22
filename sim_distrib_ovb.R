library(tidyverse)
library(mediocrethemes)
library(AER)
library(broom)

set_mediocre_all()

n <- 1000
alpha <- 0
beta <- 2
delta <- 4
lambda <- 1
sigma_x <- 0.5
sigma_u <- 0.5
sigma_v <- 0.5

sim <- function(iter) {
  u <- rnorm(n, 0, sigma_u)
  x <- delta*u + rnorm(n, 0, sigma_x)
  v <- rnorm(n, 0, sigma_v)
  y <- alpha + beta*x + delta*u + v
  fake_data <- tibble(x, y, u, v)
  reg_ovb <- lm(data = fake_data, y ~ x) %>%
    tidy() %>%
    filter(term == "x") 
  
  return(reg_ovb)
}

# sim()

simulations <- map_dfr(1:1000, sim)

simulations %>% 
  ggplot() +
  geom_histogram(aes(x = estimate)) 

+
  geom_vline(xintercept = beta)

mean(simulations$estimate)
sd(simulations$estimate)

#expected bias (should be equal to delta^2*sigma_u^2)
mean(simulations$estimate) - beta
delta^2*sigma_u^2



n <- 1000
alpha <- 0
beta <- 2
delta <- 2
gamma <- 1
lambda <- 1
sigma_x <- 0.5
sigma_u <- 0.5
sigma_v <- 0.5
n <- 10000
u <- rnorm(n, 0, sigma_u)
x <- delta*u + rnorm(n, 0, sigma_x)
v <- rnorm(n, 0, sigma_v)
y <- alpha + beta*x + gamma*u + v
fake_data <- tibble(x, y, u, v)

reg_true <- lm(data = fake_data, y ~ x + u)

reg_true %>%
  tidy() %>%
  filter(term == "x")

reg_ovb <- lm(data = fake_data, y ~ x) 

reg_ovb %>%
  tidy() %>%
  filter(term == "x") 

sqrt(var(residuals(reg_true)) / t(x) %*% x)

sqrt(var(residuals(reg_ovb)) / t(x) %*% x)

sqrt( (sigma_v^2 + delta^2*sigma_u^2) / (t(x) %*% x) )

#bias (should be equal to delta*gamma*sigma_u^2)
delta*gamma*sigma_u^2


















