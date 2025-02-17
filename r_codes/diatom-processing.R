library(tidyverse)
library(R.matlab)

diatom <- read_csv('data/barron-diatoms.csv') %>%
  mutate(across(everything(), ~replace_na(.x, 0)))

diatom_post <- diatom %>% 
  filter(Age < 11) %>% 
  arrange(Age) %>%
  select(-Depth, -Age, -Num.counted)

diatom_pre <- diatom %>% 
  filter(Age > 11) %>% 
  arrange(Age) %>%
  select(-Depth, -Age, -Num.counted)

writeMat('data/diatom.mat', pre = diatom_pre, post = diatom_post)
