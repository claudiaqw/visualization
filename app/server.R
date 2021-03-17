library(shiny)
library(ggplot2)


function(input, output) {
  
  artists <- read.csv(file = './data/artists.csv')
  
  
  output$barplot <-  renderPlotly({
    top_ten <-artists %>% 
      arrange(desc(listeners)) %>% 
      top_n(20)
    
    top_ten %>% 
      ggplot(aes(x = name, y = listeners, fill=listeners)) +
      geom_bar(stat="identity") +
      coord_flip()
  })
}