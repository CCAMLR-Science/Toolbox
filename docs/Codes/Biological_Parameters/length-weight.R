#### Estimates of TOP length-weight relationship at Subarea 48.3 ####
# Authors: S. Alewijnse

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

# add year, sex and length
length_dat <- data.frame(Year = round(runif(n = x, min = 2009, max = 2024)),
                         Length_cm = round(runif(n = x, min = 50, max = 200)),
                         Sex = rep(c("F", "M"), x/2)) %>% data.table()
length_dat

# calculated expected weight
# values from 88.1 TOA stock annex   
a_M <- 1.247e-8
a_F <- 7.361e-9
b_M <- 2.990
b_F <- 3.105
sigma <- 0.1

# females
length_dat[Sex == "F", E_Weight := log(a_F) + log(Length_cm) * b_F]

# males
length_dat[Sex == "M", E_Weight := log(a_M) + log(Length_cm) * b_M]

# convert to natural scale
length_dat[, E_Weight := exp(E_Weight)]

# add error
length_dat[, Weight_t := rnorm(n = x, mean = E_Weight, sd = sigma * E_Weight)]

# plot
ggplot(length_dat, aes(x = Length_cm, y = Weight_t, col = Sex)) +
  geom_point(alpha = 0.2) +
  theme_bw()

# Models -----

## combined =====

# run model
combined_lw_mod <- lm(log(Weight_t) ~ log(Length_cm), 
                      data = length_dat)

# get summary
summary(combined_lw_mod)

# plot residuals
length_dat$comb_res <- combined_lw_mod$residuals
ggplot(length_dat,
       aes(x = Length_cm, y = comb_res)) +
  geom_point(alpha = 0.5) +
  theme_bw()

# get model fit - for plotting
combined_lw_effs <- as.data.frame(effects::Effect(combined_lw_mod, 
                                                  focal.predictors = c("Length_cm"), 
                                                  xlevels = list(Length_cm = seq(min(length_dat$Length_cm), 
                                                                                 max(length_dat$Length_cm), 
                                                                                 length.out = 500))))

# combine with estimates
combined_lw_est <- cbind(Ests = coef(combined_lw_mod),
                         confint(combined_lw_mod))
combined_lw_est[1, ] <- exp(combined_lw_est[1, ]) # convert to natural scale
combined_lw_est

# plot
combined_lw <- ggplot() +
  geom_point(data = length_dat, aes(x = Length_cm, y = Weight_t), 
             alpha = 0.2, col = "grey40") +
  geom_line(data = combined_lw_effs, aes(x = Length_cm, y = exp(fit))) +
  geom_ribbon(data = combined_lw_effs, aes(x = Length_cm, y = exp(fit),
                                           ymin = exp(lower), ymax = exp(upper)),
              alpha = 0.2) +
  xlab('Total length (cm)') +
  ylab('Greenweight (tonnes)') +
  theme_bw() +
  labs(tag = "C")
combined_lw

# test for significant sex effect
combined_sex_lw_mod <- lm(log(Weight_t) ~ log(Length_cm) * Sex, 
                          data = length_dat)
summary(combined_sex_lw_mod)

## females =====

# get data
female_length_dat <- length_dat[Sex == "F"]

# run model
females_lw_mod <- lm(log(Weight_t) ~ log(Length_cm), 
                     data = female_length_dat)

# get summary
summary(females_lw_mod)

# plot residuals
female_length_dat$res <- females_lw_mod$residuals
ggplot(female_length_dat,
       aes(x = Length_cm, y = res)) +
  geom_point(alpha = 0.5) +
  theme_bw()

# get model fit - for plotting
females_lw_effs <- as.data.frame(effects::Effect(females_lw_mod, 
                                                 focal.predictors = c("Length_cm"), 
                                                 xlevels = list(Length_cm = seq(min(female_length_dat$Length_cm), 
                                                                                max(female_length_dat$Length_cm), 
                                                                                length.out = 500))))

# combine with estimates
females_lw_est <- cbind(Ests = coef(females_lw_mod),
                        confint(females_lw_mod))
females_lw_est[1, ] <- exp(females_lw_est[1, ]) # convert to natural scale
females_lw_est

# plot
females_lw <- ggplot() +
  geom_point(data = female_length_dat, aes(x = Length_cm, y = Weight_t), 
             alpha = 0.2, col = "#994455") +
  geom_line(data = females_lw_effs, aes(x = Length_cm, y = exp(fit))) +
  geom_ribbon(data = females_lw_effs, aes(x = Length_cm, y = exp(fit),
                                          ymin = exp(lower), ymax = exp(upper)),
              alpha = 0.2) +
  xlab('Total length (cm)') +
  ylab('Greenweight (tonnes)') +
  theme_bw()
females_lw

## males =====

# get data
male_length_dat <- length_dat[Sex == "M"]

# run model
males_lw_mod <- lm(log(Weight_t) ~ log(Length_cm), 
                     data = male_length_dat)

# get summary
summary(males_lw_mod)

# plot residuals
male_length_dat$res <- males_lw_mod$residuals
ggplot(male_length_dat,
       aes(x = Length_cm, y = res)) +
  geom_point(alpha = 0.5) +
  theme_bw()

# get model fit - for plotting
males_lw_effs <- as.data.frame(effects::Effect(males_lw_mod, 
                                                 focal.predictors = c("Length_cm"), 
                                                 xlevels = list(Length_cm = seq(min(male_length_dat$Length_cm), 
                                                                                max(male_length_dat$Length_cm), 
                                                                                length.out = 500))))

# combine with estimates
males_lw_est <- cbind(Ests = coef(males_lw_mod),
                        confint(males_lw_mod))
males_lw_est[1, ] <- exp(males_lw_est[1, ]) # convert to natural scale
males_lw_est

# plot
males_lw <- ggplot() +
  geom_point(data = male_length_dat, aes(x = Length_cm, y = Weight_t), 
             alpha = 0.2, col = "#6699CC") +
  geom_line(data = males_lw_effs, aes(x = Length_cm, y = exp(fit))) +
  geom_ribbon(data = males_lw_effs, aes(x = Length_cm, y = exp(fit),
                                          ymin = exp(lower), ymax = exp(upper)),
              alpha = 0.2) +
  xlab('Total length (cm)') +
  ylab('Greenweight (tonnes)') +
  theme_bw()
males_lw
