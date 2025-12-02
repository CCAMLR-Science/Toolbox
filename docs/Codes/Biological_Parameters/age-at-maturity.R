#### Estimation of TOP age at maturity ####
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
age_dat <- data.table(Year = round(runif(n = x, min = 2009, max = 2024)),
                      Age = round(runif(n = x, min = 1, max = 50)),
                      Sex = rep(c("F", "M"), x/2))
age_dat

# calculate probability of maturity
# A50 values from Parker & Grimes 2010
a_50_M <- 12.8
a_50_F <- 16.6

# females
age_dat[Sex == "F", P_Mature := 1/(1 + exp(-1*(Age - a_50_F)))]

# males
age_dat[Sex == "M", P_Mature := 1/(1 + exp(-1*(Age - a_50_M)))]

# add error - simulate Bernoulli trials
age_dat[, Mature := rbinom(n = .N, size = 1, prob = P_Mature) == 1]

# reshape data
# calculate proportion mature by age
prop_mature_age <- age_dat[!is.na(Sex), .(n_mat = sum(Mature == TRUE),
                                          n_immat = sum(Mature == FALSE),
                                          prop_mat = sum(Mature == TRUE)/.N,
                                          prop_immat = sum(Mature == FALSE)/.N,
                                          .N),
                           by = "Age"]

# calculate proportion mature by age and sex
prop_mature_age_sex <- age_dat[!is.na(Sex), .(n_mat = sum(Mature == TRUE),
                                              n_immat = sum(Mature == FALSE),
                                              prop_mat = sum(Mature == TRUE)/.N,
                                              prop_immat = sum(Mature == FALSE)/.N,
                                              .N),
                               by = c("Age", "Sex")]

# Models -----

## combined ====

# run model
comb_mat_mod <- glm(cbind(n_mat, n_immat) ~ Age, data = prop_mature_age,
                    family = binomial(link = "logit"))

# get summary
summary(comb_mat_mod)

# get model fit - for table
comb_mat_preds <- as.data.frame(effects::Effect(comb_mat_mod, 
                                                focal.predictors = c("Age"), 
                                                xlevels = list(Age = seq(1, 
                                                                         max(prop_mature_age$Age), 
                                                                         by = 1))))

# combine with estimates
comb_mat_est <- cbind(Ests = coef(comb_mat_mod),
                      confint(comb_mat_mod))
comb_mat_est

# calculate age at 50 % maturity
comb_A50 <- -(comb_mat_est[1, 1]/comb_mat_est[2, 1])
comb_A50_up <- -(comb_mat_est[1, 2]/comb_mat_est[2, 2])
comb_A50_low <- -(comb_mat_est[1, 3]/comb_mat_est[2, 3])

# get model fit - for plotting
comb_mat_effs <- as.data.frame(effects::Effect(comb_mat_mod, 
                                               focal.predictors = c("Age"), 
                                               xlevels = list(Age = seq(1, 
                                                                        max(prop_mature_age_sex$Age), 
                                                                        length.out = 500))))

# plot
comb_ogive <- ggplot() +
  geom_point(data = prop_mature_age, aes(x = Age, y = prop_mat, size = n_mat + n_immat), 
             alpha = 0.5, col = "grey40") +
  geom_line(data = comb_mat_effs, aes(x = Age, y = fit)) +
  geom_ribbon(data = comb_mat_effs, aes(x = Age, y = fit, ymin = lower, ymax = upper), 
              alpha = 0.2) +
  geom_segment(aes(x = 0, xend = comb_A50, y = 0.5, yend = 0.5), 
               linetype = "dotted", col = "grey20") +
  geom_segment(aes(x = comb_A50, xend = comb_A50, y = 0, yend = 0.5), 
               linetype = "dotted", col = "grey20") +
  ylab('Proportion mature') +
  xlab('Age (years)') +
  theme_bw() +
  scale_size_continuous('N') +
  scale_x_continuous(limits = c(0, 65), breaks = seq(0, 70, 10), expand = c(0, 0)) +
  scale_y_continuous(limits = c(-0.01, 1.1), expand = c(0, 0))
comb_ogive

## females =====

# subset data
prop_mature_age_females <- prop_mature_age_sex[Sex == "F"]

# fit model
female_mat_mod <- glm(cbind(n_mat, n_immat) ~ Age, data = prop_mature_age_females,
                      family = binomial(link = "logit"))

# get summary
summary(female_mat_mod)

# get model fit - for table
female_mat_preds <- as.data.frame(effects::Effect(female_mat_mod, 
                                                  focal.predictors = c("Age"), 
                                                  xlevels = list(Age = seq(1, 
                                                                           max(prop_mature_age_females$Age), 
                                                                           by = 1))))

# get model fit - for plotting
female_mat_effs <- as.data.frame(effects::Effect(female_mat_mod, 
                                                 focal.predictors = c("Age"), 
                                                 xlevels = list(Age = seq(1, 
                                                                          max(prop_mature_age_females$Age), 
                                                                          length.out = 500))))

# combine with estimates
female_mat_est <- cbind(Ests = coef(female_mat_mod),
                        confint(female_mat_mod))
female_mat_est

# calculate age at 50 % maturity - should be close to initial values
female_A50 <- -(female_mat_est[1, 1]/female_mat_est[2, 1])
female_A50_up <- -(female_mat_est[1, 2]/female_mat_est[2, 2])
female_A50_low <- -(female_mat_est[1, 3]/female_mat_est[2, 3])

# plot
female_ogive <- ggplot() +
  geom_point(data = prop_mature_age_females, aes(x = Age, y = prop_mat, size = n_mat + n_immat), 
             alpha = 0.5, col = "#994455") +
  geom_line(data = female_mat_effs, aes(x = Age, y = fit)) +
  geom_ribbon(data = female_mat_effs, aes(x = Age, y = fit, ymin = lower, ymax = upper), 
              alpha = 0.2) +
  geom_segment(aes(x = 0, xend = female_A50, y = 0.5, yend = 0.5), 
               linetype = "dotted", col = "grey20") +
  geom_segment(aes(x = female_A50, xend = female_A50, y = 0, yend = 0.5), 
               linetype = "dotted", col = "grey20") +
  ylab('Proportion mature') +
  xlab('Age (years)') +
  theme_bw() +
  scale_size_continuous('N') +
  scale_x_continuous(limits = c(0, 65), breaks = seq(0, 70, 10), expand = c(0, 0)) +
  scale_y_continuous(limits = c(-0.01, 1.1), expand = c(0, 0))
female_ogive

## males =====

# subset data
prop_mature_age_males <- prop_mature_age_sex[Sex == "M"]

# fit model
male_mat_mod <- glm(cbind(n_mat, n_immat) ~ Age, data = prop_mature_age_males,
                      family = binomial(link = "logit"))

# get summary
summary(male_mat_mod)

# get model fit - for table
male_mat_preds <- as.data.frame(effects::Effect(male_mat_mod, 
                                                  focal.predictors = c("Age"), 
                                                  xlevels = list(Age = seq(1, 
                                                                           max(prop_mature_age_males$Age), 
                                                                           by = 1))))

# get model fit - for plotting
male_mat_effs <- as.data.frame(effects::Effect(male_mat_mod, 
                                                 focal.predictors = c("Age"), 
                                                 xlevels = list(Age = seq(1, 
                                                                          max(prop_mature_age_males$Age), 
                                                                          length.out = 500))))

# combine with estimates
male_mat_est <- cbind(Ests = coef(male_mat_mod),
                        confint(male_mat_mod))
male_mat_est

# calculate age at 50 % maturity - should be close to initial values
male_A50 <- -(male_mat_est[1, 1]/male_mat_est[2, 1])
male_A50_up <- -(male_mat_est[1, 2]/male_mat_est[2, 2])
male_A50_low <- -(male_mat_est[1, 3]/male_mat_est[2, 3])

# plot
male_ogive <- ggplot() +
  geom_point(data = prop_mature_age_males, aes(x = Age, y = prop_mat, size = n_mat + n_immat), 
             alpha = 0.5, col = "#6699CC") +
  geom_line(data = male_mat_effs, aes(x = Age, y = fit)) +
  geom_ribbon(data = male_mat_effs, aes(x = Age, y = fit, ymin = lower, ymax = upper), 
              alpha = 0.2) +
  geom_segment(aes(x = 0, xend = male_A50, y = 0.5, yend = 0.5), 
               linetype = "dotted", col = "grey20") +
  geom_segment(aes(x = male_A50, xend = male_A50, y = 0, yend = 0.5), 
               linetype = "dotted", col = "grey20") +
  ylab('Proportion mature') +
  xlab('Age (years)') +
  theme_bw() +
  scale_size_continuous('N') +
  scale_x_continuous(limits = c(0, 65), breaks = seq(0, 70, 10), expand = c(0, 0)) +
  scale_y_continuous(limits = c(-0.01, 1.1), expand = c(0, 0))
male_ogive
