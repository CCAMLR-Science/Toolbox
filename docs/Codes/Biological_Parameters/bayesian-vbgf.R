#### Bayesian estimates of TOP length and maturity using VBGF ####
# Authors: J. Marsh and S. Alewijnse

# load libraries
library(here)
library(data.table)
library(ggplot2)
library(magrittr)
library(patchwork)
library(brms)
library(beepr)
library(bayesplot)

# Create dummy data -----

# set number of points
x <- 5000

# add year, age and sex
age_dat <- data.frame(Year = round(runif(n = x, min = 2009, max = 2024)),
                      Age = round(runif(n = x, min = 1, max = 50)),
                      Sex = rep(c("F", "M"), x/2)) %>% data.table()
age_dat

# calculate expected length
# sex-disagg values from fishbase for Patagonian toothfish for Macquarie Island
Linf_F <- 158.7
Linf_M <- 134.3
k_F <- 0.085
k_M <- 0.118
t0_F <- -0.35
t0_M <- 0.08
tau <- 0.15

# females
age_dat[Sex == "F", E_Length := Linf_F * (1.0 - exp(-k_F * (Age - t0_F)))]

# males
age_dat[Sex == "M", E_Length := Linf_M * (1.0 - exp(-k_M * (Age - t0_M)))]

# add error
age_dat[, Length := rnorm(n = x, mean = E_Length, sd = tau * E_Length)]

# plot
ggplot(age_dat, aes(x = Age, y = Length, col = Sex)) +
  geom_point(alpha = 0.2) +
  theme_bw()

# Models -----

# model priors
priors <- c(
  prior(normal(100, 100), nlpar = "Linf", lb = 0),
  prior(normal(0, 3), nlpar = "k", lb = 0),
  prior(normal(0, 1), nlpar = "tau", lb = 0),
  prior(normal(0, 3), nlpar = "t0")
)

# create function containing model
vbgf_mod <- function(data){
  mod_fit <- brm(bf(
    # set out the function
    Length ~ eta, nl = TRUE) + # non-linear = TRUE
      nlf(eta ~ 1 + Linf * (1.0 - exp(-k * (Age - t0)))) + # VBGF
      nlf(sigma ~ eta * tau) + # error increases with increasing age
      lf(Linf ~ 1, k ~ 1,  tau ~ 1, t0 ~ 1),
    data = data, 
    chains = 3, cores = getOption("mc.cores", 3), # three chains running across three cores
    prior = priors, # use priors defined above
    family = brmsfamily("gaussian", link_sigma = "identity"), # Normal distribution
    iter = 10000, # 5000 warmup (discarded), 5000 actual iterations
    thin = 10, # retain every tenth sample (reduces autocorrelation)
    control = list(adapt_delta = 0.9)) # increased adapt_delta for more careful sampling
  return(mod_fit)
}

# Run combined model -----

# run model
vbgf_mod_comb <- vbgf_mod(age_dat);beep() # beep when done - it will take a while

# view summary
print(summary(vbgf_mod_comb), digits = 4)

# quick plots
plot(vbgf_mod_comb)
bayesplot::mcmc_pairs(vbgf_mod_comb)

## plot predictions =====

# create new data
new_data_comb <- data.frame(Age = seq(min(age_dat$Age), max(age_dat$Age), 0.01))

# get predictions
vbgf_pred_comb <- brms::posterior_epred(vbgf_mod_comb, newdata = new_data_comb)
vbgf_pred_comb <- data.frame(
  Age = new_data_comb$Age,
  mean = colMeans(vbgf_pred_comb),
  ci_low = apply(vbgf_pred_comb, 2, quantile, probs = 0.025),
  ci_up = apply(vbgf_pred_comb, 2, quantile, probs = 0.975)
)

# plot
vbgf_plot_comb <- ggplot() +
  geom_point(data = age_dat, 
             aes(x = Age, y = Length, col = Sex), alpha = 0.2) +
  geom_line(data = vbgf_pred_comb, 
            aes(x = Age, y = mean)) +
  geom_ribbon(data = vbgf_pred_comb, 
              aes(x = Age, ymin = ci_low, ymax = ci_up), alpha = 0.2) +
  theme_bw() +
  theme(legend.position = "none")
vbgf_plot_comb

## diagnostic plots =====

# create a function to combine all plots
mcmcDiag <- function(model, param, param_lab, col, title){
  # set colour scheme
  bayesplot::color_scheme_set(col)
  # density overlay
  dens <- bayesplot::mcmc_dens_overlay(model, pars = param) +
    theme_bw() +
    xlab(param_lab) +
    theme(legend.position = "none") +
    ggtitle(title)
  # traceplot
  trace <- bayesplot::mcmc_trace(model, pars = param) +
    theme_bw() +
    ylab(param_lab) +
    xlab("Post-warmup iterations") +
    theme(legend.position = "none")
  trace 
  # autocorrelation function
  acf <- bayesplot::mcmc_acf_bar(model, pars = param) +
    theme_bw() +
    theme(strip.text.x = element_blank())
  # combine
  diag_plot <- (dens + trace) / acf
  return(diag_plot)
}

# L_inf
combined_linf <- mcmcDiag(model = vbgf_mod_comb, 
                          param = "b_Linf_Intercept", param_lab = "L_inf",
                          col = "darkgray", title = "Combined L_inf")
combined_linf

# k
combined_k <- mcmcDiag(model = vbgf_mod_comb, 
                       param = "b_k_Intercept", param_lab = "k",
                       col = "darkgray", title = "Combined k")
combined_k

# t0
combined_t0 <- mcmcDiag(model = vbgf_mod_comb, 
                        param = "b_t0_Intercept", param_lab = "t0",
                        col = "darkgray", title = "Combined t0")
combined_t0

# tau
combined_tau <- mcmcDiag(model = vbgf_mod_comb, 
                         param = "b_tau_Intercept", param_lab = "tau",
                         col = "darkgray", title = "Combined tau")
combined_tau

# run female model -----

# run model
vbgf_mod_female <- vbgf_mod(age_dat[Sex == "F"]);beep() # beep when done - it will take a while

# view summary
print(summary(vbgf_mod_female), digits = 4) # should be close to set values

# quick plots
plot(vbgf_mod_female)
bayesplot::mcmc_pairs(vbgf_mod_female)

## plot predictions =====

# create new data
new_data_female <- data.frame(Age = seq(min(age_dat[Sex == "F"]$Age), 
                                        max(age_dat[Sex == "F"]$Age), 0.01))

# get predictions
vbgf_pred_female <- brms::posterior_epred(vbgf_mod_female, newdata = new_data_female)
vbgf_pred_female <- data.frame(
  Age = new_data_female$Age,
  Sex = "F",
  mean = colMeans(vbgf_pred_female),
  ci_low = apply(vbgf_pred_female, 2, quantile, probs = 0.025),
  ci_up = apply(vbgf_pred_female, 2, quantile, probs = 0.975)
)

# plot
vbgf_plot_female <- ggplot() +
  geom_point(data = age_dat[Sex == "F"], 
             aes(x = Age, y = Length), 
             alpha = 0.2, col = "#BB5566") +
  geom_line(data = vbgf_pred_female, 
            aes(x = Age, y = mean)) +
  geom_ribbon(data = vbgf_pred_female, 
              aes(x = Age, ymin = ci_low, ymax = ci_up), 
              alpha = 0.2) +
  theme_bw() +
  theme(legend.position = "none")
vbgf_plot_female

## diagnostic plots =====

# L_inf
female_linf <- mcmcDiag(model = vbgf_mod_comb, 
                          param = "b_Linf_Intercept", param_lab = "L_inf",
                          col = "red", title = "Female L_inf")
female_linf

# k
female_k <- mcmcDiag(model = vbgf_mod_comb, 
                       param = "b_k_Intercept", param_lab = "k",
                       col = "red", title = "Female k")
female_k

# t0
female_t0 <- mcmcDiag(model = vbgf_mod_comb, 
                        param = "b_t0_Intercept", param_lab = "t0",
                        col = "red", title = "Female t0")
female_t0

# tau
female_tau <- mcmcDiag(model = vbgf_mod_comb, 
                         param = "b_tau_Intercept", param_lab = "tau",
                         col = "red", title = "Female tau")
female_tau

# run male model -----

# run model
vbgf_mod_male <- vbgf_mod(age_dat[Sex == "M"]);beep() # beep when done - it will take a while

# view summary
print(summary(vbgf_mod_male), digits = 4) # should be close to set values

# quick plots
plot(vbgf_mod_male)
bayesplot::mcmc_pairs(vbgf_mod_male)

## plot predictions =====

# create new data
new_data_male <- data.frame(Age = seq(min(age_dat[Sex == "M"]$Age), 
                                        max(age_dat[Sex == "M"]$Age), 0.01))

# get predictions
vbgf_pred_male <- brms::posterior_epred(vbgf_mod_male, newdata = new_data_male)
vbgf_pred_male <- data.frame(
  Age = new_data_male$Age,
  Sex = "M",
  mean = colMeans(vbgf_pred_male),
  ci_low = apply(vbgf_pred_male, 2, quantile, probs = 0.025),
  ci_up = apply(vbgf_pred_male, 2, quantile, probs = 0.975)
)

# plot
vbgf_plot_male <- ggplot() +
  geom_point(data = age_dat[Sex == "M"], 
             aes(x = Age, y = Length), 
             alpha = 0.2, col = "#004488") +
  geom_line(data = vbgf_pred_male, 
            aes(x = Age, y = mean)) +
  geom_ribbon(data = vbgf_pred_male, 
              aes(x = Age, ymin = ci_low, ymax = ci_up), 
              alpha = 0.2) +
  theme_bw() +
  theme(legend.position = "none")
vbgf_plot_male

## diagnostic plots =====

# L_inf
male_linf <- mcmcDiag(model = vbgf_mod_comb, 
                        param = "b_Linf_Intercept", param_lab = "L_inf",
                        col = "blue", title = "Male L_inf")
male_linf

# k
male_k <- mcmcDiag(model = vbgf_mod_comb, 
                     param = "b_k_Intercept", param_lab = "k",
                     col = "blue", title = "Male k")
male_k

# t0
male_t0 <- mcmcDiag(model = vbgf_mod_comb, 
                      param = "b_t0_Intercept", param_lab = "t0",
                      col = "blue", title = "Male t0")
male_t0

# tau
male_tau <- mcmcDiag(model = vbgf_mod_comb, 
                       param = "b_tau_Intercept", param_lab = "tau",
                       col = "blue", title = "Male tau")
male_tau
