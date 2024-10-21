library(tidyverse)
library(R.matlab)
library(igraph)
library(xtable)

diatom <- read_csv('data/barron-diatoms.csv') %>%
  mutate(across(everything(), ~replace_na(.x, 0))) %>%
  rename(actinocyclus.curvatulus = A_curv,
         actinocyclus.octonarius = A_octon,
         actinoptychus.spp = ActinSpp,
         azpeitia.nodulifer = A_nodul,
         coscinodiscus.spp = CoscinSpp,
         cyclotella.spp = CyclotSpp,
         roperia.tesselata = Rop_tess,
         stephanopyxis.spp = StephanSpp)

## FIGURE: COUNTS OVER TIME

taxon_counts <- diatom %>%
  select(-Num.counted) %>%
  arrange(desc(Depth)) %>%
  pivot_longer(cols = -c(Depth, Age), 
               names_to = 'taxon', values_to = 'Count') %>%
  ggplot(aes(x = Age, y = Count)) +
  facet_wrap(~taxon, nrow = 2) +
  geom_path() +
  labs(x = 'Thousands of years before present') +
  geom_vline(xintercept = 11, color = 'red', linetype = 'dashed') +
  theme_bw()
  
ggsave(taxon_counts, filename = 'results/fig-diatom-counts.png',
       width = 8, height = 5, units = 'cm', dpi = 400, scale = 2)

## FIGURE: CHANGE IN NETWORK STRUCTURE BEFORE AND AFTER CLIMATE EVENT
mat_out_post <- readMat('results/diatom-post.mat')
mat_out_pre <- readMat('results/diatom-pre.mat')


plot_fn_post <- function(ix, lbl){
  
a_mx <- mat_out_post$rslts.post[ix, 1][[1]][[1]]
colnames(a_mx) <- rownames(a_mx) <- colnames(diatom)[3:10]

graph_from_adjacency_matrix(a_mx, weighted = T) %>%
  plot(edge.arrow.size = 0.2,
       vertex.size = 10,
       vertex.label.dist = 1.5,
       vertex.label.degree = 1,
       vertex.label.cex = 0.8,
       vertex.label.family = 'sans',
       vertex.color = 'gray50',
       vertex.label.color = 'black',
       layout = layout_in_circle,
       main = lbl)
}
plot_fn_pre <- function(ix, lbl){
  
  a_mx <- mat_out_pre$rslts.pre[ix, 1][[1]][[1]]
  colnames(a_mx) <- rownames(a_mx) <- colnames(diatom)[3:10]
  
  graph_from_adjacency_matrix(a_mx, weighted = T) %>%
    plot(edge.arrow.size = 0.2,
         vertex.size = 10,
         vertex.label.dist = 1.5,
         vertex.label.degree = 1,
         vertex.label.cex = 0.8,
         vertex.label.family = 'sans',
         vertex.color = 'gray50',
         vertex.label.color = 'black',
         layout = layout_in_circle,
         main = lbl)
}


png(filename = 'results/fig-diatom-graphs.png', 
    width = 20, height = 10, units = 'cm', res = 400)

par(mar = c(2, 2, 2, 2), mfrow = c(2, 3)) 

plot_fn_pre(1, 'Naive method')
mtext('Pleistocene', side = 2)
plot_fn_pre(2, 'Benchmark method')
plot_fn_pre(3, 'Aggregation method')
plot_fn_post(1, '')
mtext('Holocene', side = 2)
plot_fn_post(2, '')
plot_fn_post(3, '')

dev.off()

## TABLES: PARAMETER ESTIMATES

a_post_naive <- mat_out_post$rslts.post[1, 1][[1]][[1]] 
a_post_bench <- mat_out_post$rslts.post[2, 1][[1]][[1]] 
a_post <- mat_out_post$rslts.post[3, 1][[1]][[1]] 

a_pre_naive <- mat_out_pre$rslts.pre[1, 1][[1]][[1]] 
a_pre_bench <- mat_out_pre$rslts.pre[2, 1][[1]][[1]] 
a_pre <- mat_out_pre$rslts.pre[3, 1][[1]][[1]]

pre_estimates <- expand_grid(Origin = colnames(diatom)[3:10],
                             Terminus = colnames(diatom)[3:10]) |>
  bind_cols(Naive = c(mat_out_pre$rslts.pre[1, 1][[1]][[1]]),
            Benchmark = c(mat_out_pre$rslts.pre[2, 1][[1]][[1]]),
            Aggregation = c(mat_out_pre$rslts.pre[3, 1][[1]][[1]])) |>
  filter((Naive != 0) + (Benchmark != 0) + (Aggregation !=0) > 0)

post_estimates <- expand_grid(Origin = colnames(diatom)[3:10],
                             Terminus = colnames(diatom)[3:10]) |>
  bind_cols(Naive = c(mat_out_post$rslts.post[1, 1][[1]][[1]]),
            Benchmark = c(mat_out_post$rslts.post[2, 1][[1]][[1]]),
            Aggregation = c(mat_out_post$rslts.post[3, 1][[1]][[1]])) |>
  filter((Naive != 0) + (Benchmark != 0) + (Aggregation !=0) > 0)

fn <- function(x){
  if(abs(x) < 0.0001){
    out <- '<0.0001'
  }else{
    out <- sprintf("%.4f", x) |> as.character()
  }
  return(out)
}

pre_estimates |>
  mutate(across(c(Origin, Terminus), ~str_replace(.x, '\\.', ' '))) |>
  mutate(across(c(Naive, Benchmark, Aggregation), 
                ~ na_if(.x, 0))) |>
  mutate(across(c(Naive, Benchmark, Aggregation), 
                ~if_else(abs(.x) < 0.001, '|a|<0.001', sprintf("%.3f", .x)))) |>
  xtable() |>
  print(include.rownames = F, include.colnames = T) |>
  clipr::write_clip()


post_estimates |>
  mutate(across(c(Origin, Terminus), ~str_replace(.x, '\\.', ' '))) |>
  mutate(across(c(Naive, Benchmark, Aggregation), 
                ~ na_if(.x, 0))) |>
  mutate(across(c(Naive, Benchmark, Aggregation), 
                ~if_else(abs(.x) < 0.001, '|a|<0.001', sprintf("%.3f", .x)))) |>
  xtable() |>
  print(include.rownames = F, include.colnames = T) |>
  clipr::write_clip()
