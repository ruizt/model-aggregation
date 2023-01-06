library(tidyverse)
library(R.matlab)
library(igraph)

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
  geom_vline(xintercept = 11, color = 'red', linetype = 'dashed')
  
ggsave(taxon_counts, filename = 'results/fig-diatom-counts.png',
       width = 12, height = 6, units = 'cm', dpi = 400, scale = 2)

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
