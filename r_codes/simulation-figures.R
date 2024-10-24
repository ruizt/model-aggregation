library(tidyverse)
library(R.matlab)
library(patchwork)
options(stringsAsFactors = F)
mat_dir <- "results/simulation_results"

## LOAD AND ORGANIZE DATA FOR PLOTTING

sim_out <- Reduce(rbind, lapply(c(10, 15, 20), function(x){
csv_file <- paste('sim_p', x, '_resultTbl.csv', sep = '')
resultTbl <- read.csv(paste(mat_dir, csv_file, sep = '/')) %>%
  as_tibble() %>%
  rename(p = settings_1, 
         sparsity = settings_2) %>%
  group_by(p, sparsity, parameter.ID, `T`) %>%
  mutate(dataset = 1:5) %>%
  ungroup() %>%
  group_by(p, sparsity) %>%
  mutate(parameter.rep = rep(1:10, each = 15)) %>%
  ungroup()
return(resultTbl)}))

## check for convergence issues (should see zeros)
apply(sim_out[, 22:25], 2, sum)

## reshape data
fp <- sim_out %>%
  select(c(1:5, 6:9, 26:27)) %>%
  rename(`Baseline` = fp_1,
         `Stabilization` = fp_2,
         `Model Aggregation` = fp_3,
         `Stbl. + Mdl. Aggr.` = fp_4) %>%
  gather("Method", "fp", 6:9)


fn <- sim_out %>%
  select(c(1, 4:5, 10:13, 26:27)) %>%
  rename(`Baseline` = fn_1,
         `Stabilization` = fn_2,
         `Model Aggregation` = fn_3,
         `Stbl. + Mdl. Aggr.` = fn_4) %>%
  gather("Method", "fn", 3:6 + 1)

mse <- sim_out %>%
  select(c(1, 4:5, 14:17, 26:27)) %>%
  rename(`Baseline` = mse_1,
         `Stabilization` = mse_2,
         `Model Aggregation` = mse_3,
         `Stbl. + Mdl. Aggr.` = mse_4) %>%
  gather("Method", "mse", 3:6 + 1)

compTime <- sim_out %>%
  select(c(1, 4:5, 18:21, 26:27)) %>%
  rename(`Baseline` = compTime_1,
         `Stabilization` = compTime_2,
         `Model Aggregation` = compTime_3,
         `Stbl. + Mdl. Aggr.` = compTime_4) %>%
  gather("Method", "compTime", 3:6 + 1)

plot_df <- merge(fp, 
      fn, 
      by = c('p', 'parameter.ID', 'T', 'Method', 'dataset', 'parameter.rep')) %>%
  merge(mse, 
        by = c('p', 'parameter.ID', 'T', 'Method', 'dataset', 'parameter.rep')) %>%
  merge(compTime, 
        by = c('p', 'parameter.ID', 'T', 'Method', 'dataset', 'parameter.rep')) %>%
  as_tibble() %>%
  mutate(p.fac = factor(p, labels = c('M = 10', 'M = 15', 'M = 20')),
         sparsity.fac = factor(sparsity, labels = c('s = 0.01', 's = 0.02', 's = 0.05')),
         `Support Estimation` = if_else(str_detect(Method, 'St'), 
                           'Support Aggregation',
                           'Lasso Supports'),
         `Support Selection` = if_else(str_detect(Method, 'Agg'),
                              'Model Aggregation',
                              'Cross Validation'))

## FIGURE: AVERAGE SELECTION ERRORS

# # version 1
# plot_df %>%
#   group_by(p, sparsity, 
#            p.fac, sparsity.fac, 
#            `T`, Method,
#            `Support Estimation`, 
#            `Support Selection`) %>%
#   summarize(fp = mean(fp),
#             fn = mean(fn),
#             compTime = mean(compTime),
#             mse = mean(mse)) %>%
# ggplot(aes(x = `T`, 
#            y = (fn + fp)/round(p^2*sparsity),
#            color = `Support Selection`,
#            linetype = `Support Estimation`)) +
#   geom_path() +
#   facet_wrap(~sparsity.fac*p.fac) +
#   theme_bw() +
#   labs(y = expression(paste("Average  ", frac(FP + FN, sM^2)))) +
#   scale_color_manual(values = c('red', 'blue'))


# version 2
selection_errors <- plot_df %>%
  group_by(p, sparsity, 
           p.fac, sparsity.fac, 
           `T`, Method,
           `Support Estimation`, 
           `Support Selection`) %>%
  summarize(fp = mean(fp),
            fn = mean(fn),
            compTime = mean(compTime),
            mse = mean(mse)) %>%
  ggplot(aes(x = `T`, 
             y = (fn + fp)/(p^2),
             color = `Support Selection`,
             linetype = `Support Estimation`)) +
  geom_path(linewidth = 0.3) +
  geom_point(alpha = 0.75, aes(shape = `Support Selection`)) +
  facet_wrap(~sparsity.fac*p.fac) +
  theme_bw() +
  labs(y = expression(paste("Average  ", frac(FP + FN, M^2))),
       x = 'Series length (T)') +
  scale_color_manual(values = c('red', 'blue')) +
  theme(panel.grid.major = element_line(color = 'black', linewidth = 0.1),
        panel.grid.minor = element_blank(),
        axis.text.x = element_text(angle = 90))

# save
ggsave(selection_errors, filename = 'results/fig-selection-errors.png', 
       height = 5, width = 6, scale = 1, units = 'in', dpi = 400)

## FIGURE: FALSE POSITIVE AND FALSE NEGATIVE RATES

# left panel (no legend)
panel_fn <- plot_df %>%
  group_by(p, sparsity, 
           p.fac, sparsity.fac, 
           `T`, Method,
           `Support Estimation`, 
           `Support Selection`) %>%
  summarize(fp = mean(fp),
            fn = mean(fn),
            compTime = mean(compTime),
            mse = mean(mse)) %>%
  ggplot(aes(x = `T`, 
             y = fn/(p^2),
             color = `Support Selection`,
             linetype = `Support Estimation`)) +
  geom_path(linewidth = 0.3) +
  geom_point(alpha = 0.75, aes(shape = `Support Selection`)) +
  facet_wrap(~sparsity.fac*p.fac) +
  theme_bw() +
  scale_y_continuous(n.breaks = 4) +
  labs(y = expression(paste("Average ", frac(FN, M^2))),
       title = 'False negatives',
       x = 'Series length (T)') +
  scale_color_manual(values = c('red', 'blue')) +
  guides(color = guide_none(), linetype = guide_none(), shape = guide_none())  +
  theme(axis.text.x = element_text(angle = 90),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_line(color = 'black', linewidth = 0.1))

# right panel  (legend)
panel_fp <- plot_df %>%
  group_by(p, sparsity, 
           p.fac, sparsity.fac, 
           `T`, Method,
           `Support Estimation`, 
           `Support Selection`) %>%
  summarize(fp = mean(fp),
            fn = mean(fn),
            compTime = mean(compTime),
            mse = mean(mse)) %>%
  ggplot(aes(x = `T`, 
             y = fp/(p^2),
             color = `Support Selection`,
             linetype = `Support Estimation`)) +
  geom_path(linewidth = 0.3) +
  geom_point(alpha = 0.75, aes(shape = `Support Selection`)) +
  facet_wrap(~sparsity.fac*p.fac) +
  theme_bw() +
  labs(y = expression(paste("Average ", frac(FP, M^2))),
       title = 'False positives',
       x = 'Series length (T)') +
  scale_color_manual(values = c('red', 'blue')) +
  theme(axis.text.x = element_text(angle = 90),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_line(color = 'black', linewidth = 0.1))

# combine panels
fpfn_rates <- panel_fn + panel_fp + 
  plot_layout(ncol = 2, nrow = 1, widths = c(1, 1))

# save
ggsave(fpfn_rates, filename = 'results/fig-fpfn-rates.png', 
       height = 5, width = 8.5, scale = 1, units = 'in', dpi = 400)


## FIGURE: MARGINAL EFFECTS OF ALGORITHM FEATURES

# support aggregation vs lasso supports (left panel)
fpfn_lasso <- sim_out %>%
  mutate(fpfn_1 = fp_1 + fn_1,
         fpfn_3 = fp_3 + fn_3) %>%
  select(c(1:2, 4:5), fpfn_1, fpfn_3, dataset) %>%
  rename(`Cross Validation` = fpfn_1,
         `Model Aggregation` = fpfn_3) %>%
  gather('Validation', 'fpfn', 5:6) %>%
  rename(fpfn.lasso = fpfn)

fpfn_aggr <- sim_out %>%
  mutate(fpfn_2 = fp_2 + fn_2,
         fpfn_4 = fp_4 + fn_4) %>%
  select(c(1:2, 4:5), fpfn_2, fpfn_4, dataset) %>%
  rename(`Cross Validation` = fpfn_2,
         `Model Aggregation` = fpfn_4) %>%
  gather('Validation', 'fpfn', 5:6) %>%
  rename(fpfn.aggr = fpfn)

margin1_plot_df <- merge(fpfn_lasso, fpfn_aggr,
                 by = c('p', 'sparsity', 'parameter.ID', 'T', 'dataset', 'Validation'))

support_panel <- margin1_plot_df %>%
  mutate(p.fac = factor(p, labels = c('M = 10', 'M = 15', 'M = 20')),
         sparsity.fac = factor(sparsity, 
                               labels = c('s = 0.01', 's = 0.02', 's = 0.05'))) %>%
  ggplot(aes(x = fpfn.lasso/(p^2),
             y = fpfn.aggr/(p^2))) +
  geom_jitter(alpha = 0.1,
              width = 0.002,
              height = 0.002) +
  facet_wrap(~sparsity.fac*p.fac) +
  geom_abline(slope = 1,
              intercept = 0,
              linewidth = 0.25) +
  geom_smooth(method = 'lm', se = F, 
              color = 'red', lty = 2,
              linewidth = 0.4) +
  theme_bw() +
  coord_fixed(ratio = 1) +
  labs(x = expression(paste(frac(FP + FN, M^2), '  for lasso support methods')),
       y = expression(paste(frac(FP + FN, M^2), '  for support aggregation methods'))) +
  theme(axis.text.x = element_text(angle = 90),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_line(color = 'black', linewidth = 0.1))


# effect of model selection vs. aggregation (right panel)
fpfn_cv <- sim_out %>%
  mutate(fpfn_1 = fp_1 + fn_1,
         fpfn_2 = fp_2 + fn_2) %>%
  select(c(1:2, 4:5), fpfn_1, fpfn_2, dataset) %>%
  rename(`Lasso Supports` = fpfn_1,
         `Support Aggregation` = fpfn_2) %>%
  gather('Support Estimation', 'fpfn', 5:6) %>%
  rename(fpfn.cv = fpfn)

fpfn_mdlagg <- sim_out %>%
  mutate(fpfn_3 = fp_3 + fn_3,
         fpfn_4 = fp_4 + fn_4) %>%
  select(c(1:2, 4:5), fpfn_3, fpfn_4, dataset) %>%
  rename(`Lasso Supports` = fpfn_3,
         `Support Aggregation` = fpfn_4) %>%
  gather('Support Estimation', 'fpfn', 5:6) %>%
  rename(fpfn.aggr = fpfn)

margin2_plot_df <- merge(fpfn_cv, fpfn_mdlagg,
                 by = c('p', 'sparsity', 'parameter.ID', 'T', 'dataset', 'Support Estimation'))

model_panel <- margin2_plot_df %>%
  mutate(p.fac = factor(p, labels = c('M = 10', 'M = 15', 'M = 20')),
         sparsity.fac = factor(sparsity, 
                               labels = c('s = 0.01', 's = 0.02', 's = 0.05'))) %>%
  ggplot(aes(x = fpfn.cv/(p^2),
             y = fpfn.aggr/(p^2))) +
  geom_jitter(alpha = 0.1,
              width = 0.002,
              height = 0.002) +
  facet_wrap(~sparsity.fac*p.fac) +
  geom_abline(slope = 1,
              intercept = 0,
              linewidth = 0.25) +
  geom_smooth(method = 'lm', se = F, 
              color = 'red', lty = 2, 
              linewidth = 0.4) +
  theme_bw() +
  coord_fixed(ratio = 1) +
  labs(x = expression(paste(frac(FP + FN, M^2), '  for cross validation methods')),
       y = expression(paste(frac(FP + FN, M^2), '  for model aggregation methods'))) +
  theme(axis.text.x = element_text(angle = 90),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_line(color = 'black', linewidth = 0.1))

# combine panels
marginal_effects <- support_panel + model_panel + 
  plot_layout(ncol = 2, widths = c(1, 1))

# save
ggsave(marginal_effects, filename = 'results/fig-marginal-effects.png', 
       height = 5, width = 8, scale = 1, units = 'in', dpi = 400)


## SUPPLEMENTAL FIGURE: MSE OF PARAMETER ESTIMATES
 
mse_avg <- plot_df %>%
  group_by(p, sparsity, 
           parameter.rep,
           p.fac, sparsity.fac, 
           `T`, Method,
           `Support Estimation`, 
           `Support Selection`) %>%
  summarize(fp = mean(fp),
            fn = mean(fn),
            compTime = mean(compTime),
            mse = mean((p^2)*mse))

# mse against t
mse_fig <- plot_df %>%
  na.omit() %>%
  group_by(p, sparsity, 
           p.fac, sparsity.fac, 
           `T`, Method,
           `Support Estimation`, 
           `Support Selection`) %>%
  summarize(fp = mean(fp),
            fn = mean(fn),
            compTime = mean(compTime),
            mse = mean((p^2)*mse)) %>%
  ggplot(aes(x = `T`, 
             y = mse,
             color = `Support Selection`,
             linetype = `Support Estimation`)) +
  geom_path(linewidth = 0.5) +
  geom_path(data = mse_avg, alpha = 0.1, linewidth = 0.3) +
  facet_wrap(~sparsity.fac*p.fac) +
  theme_bw() +
  theme(panel.grid.minor = element_blank(),
        panel.grid.major = element_line(color = 'black', linewidth = 0.1),
        axis.text.x = element_text(angle = 90)) +
  scale_y_log10() +
  labs(y = expression(paste("Average  ", 
                            group("|", group("|", A - hat(A), "|"), "|")['F'])),
       x = 'Series length (T)') +
  scale_color_manual(values = c('red', 'blue'))

ggsave(mse_fig, filename = 'results/sfig-mse.png', 
       height = 4, width = 5, scale = 1.1, units = 'in', dpi = 400)

## SUPPLEMENTAL FIGURE: COMPUTATION TIMES OBSERVED IN SIMULATION

comp_fig <- plot_df %>%
  group_by(p, sparsity, 
           p.fac, sparsity.fac, 
           `T`, Method,
           `Support Selection`, 
           `Support Estimation`) %>%
  summarize(fp = mean(fp),
            fn = mean(fn),
            compTime = mean(compTime),
            mse = mean((p^2)*mse)) %>%
  ggplot(aes(x = `T`, 
             y = compTime,
             linetype = `Support Estimation`,
             color = `Support Selection`)) +
  geom_path() +
  facet_wrap(~sparsity.fac*p.fac) +
  theme_bw() +
  scale_y_log10() +
  labs(y = "Average compute time (sec)",
       x = 'Series length (T)') +
  scale_color_manual(values = c('red', 'blue')) +
  guides(color = guide_legend(), linetype = guide_legend()) +
  theme(panel.grid.minor = element_blank(),
        panel.grid.major = element_line(color = 'black', linewidth = 0.1),
        axis.text.x = element_text(angle = 90))

ggsave(comp_fig, filename = 'results/sfig-comp.png', 
       height = 4, width = 5, scale = 1.1, units = 'in', dpi = 400)
