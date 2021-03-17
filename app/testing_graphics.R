library(ggplot2)
library(dplyr)

artists <- read.csv(file = './data/artists.csv')
head(artists)

top_ten <-artists %>% 
  arrange(desc(listeners)) %>% 
  top_n(20)
  

top_ten %>% 
  ggplot(aes(x = name, y = listeners, fill=listeners)) +
  geom_bar(stat="identity") %>% 
  coord_flip()


