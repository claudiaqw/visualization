library(shiny)
library(ggplot2)
library(rgdal)
library(leaflet)
library(rgdal)
library(ggthemes)
library(sp)
library(rworldmap)
library(dplyr)


function(input, output) {
  
  artists <- read.csv(file = './data/artists.csv')
  tracks <- read.csv(file = './data/tracks.csv')
  
  top_artists <- read.csv(file='./data/top_artists_per_country.csv')
  top_tracks <- read.csv(file='./data/top_tracks_per_country.csv')
  
  serie.df <- read.csv(file='./data/artist_by_user_serie.csv') 
  serie.df$date <- as.Date(serie.df$date)
  
  countries <- readOGR("data/countries.geo.json")
  
  default_country <-'Spain'
  
  get_country <- function(coord){
    p <- coord
    df = data.frame(lon=c(p[2]), lat=c(p[1]))
    country <- coords2country(df)
    country
  }
  
  coords2country = function(points)
  {  
    countriesSP <- getMap(resolution='low')
    pointsSP = SpatialPoints(points, proj4string=CRS(proj4string(countriesSP))) 
    indices = over(pointsSP, countriesSP)
    indices$ADMIN  
    #indices$ISO3 # returns the ISO3 code
  }
  
  output$barplot <-  renderPlotly({
    top_ten <-artists %>% 
      arrange(desc(listeners)) %>% 
      top_n(20)
    
    top_ten %>% 
      ggplot(aes(x = name, y = listeners)) +
      geom_bar(stat="identity",  fill = "#B90000") +
      coord_flip()+
      theme_ipsum()
  })
  
  output$track_barplot <-renderPlotly({
    top_ten_tracks <-tracks %>% 
      arrange(desc(playcount)) %>% 
      top_n(20)
    
    top_ten_tracks %>% ggplot() +
      geom_bar(aes(x=name, y=playcount), stat="identity", fill = "#B90000") +
      geom_bar(aes(x=name, y=listeners), stat="identity", fill = "blue") +
      coord_flip() +
      theme_ipsum()
  })
  
  output$barplot_tracks <- renderPlotly({
    top_ten_tracks <-tracks %>% 
      arrange(desc(listeners)) %>% 
      top_n(20)
    
    top_ten_tracks %>% 
      ggplot(aes(x = name, y = listeners)) +
      geom_bar(stat="identity",  fill = "#B90000") +
      coord_flip()+
      theme_few()
  })
  
  output$artist_serie <- renderPlotly({
    artist.filtered <- serie.df %>% 
      filter(artist == input$artist_name) %>% 
      group_by(date) %>% 
      summarise(count = n())
    
    artist.filtered %>% 
      ggplot(aes(x=date, y=count)) +
      geom_line(color="#69b3a2") +
      xlab("") +
      theme_ipsum()
    
  })
  
  
  output$top_artists_by_country <- renderPlotly({
    
    p <- input$map_click
    df = data.frame(lon=c(p[2]), lat=c(p[1]))
    default_country <- coords2country(df)
    print(default_country)
    
    
    top_artists %>% 
      filter(country == default_country) %>% 
      arrange(rank) %>% 
      ggplot(aes(x = artist, y = listeners)) +
      geom_bar(stat="identity",  fill = "#B90000") +
      coord_flip()+
      theme_few()
  })
  
  output$top_tracks_by_country <- renderPlotly({
    
    p <- input$map_click
    df = data.frame(lon=c(p[2]), lat=c(p[1]))
    default_country <- coords2country(df)
    print(default_country)
    
    top_tracks %>% 
      filter(country == default_country) %>% 
      arrange(rank) %>% 
      ggplot(aes(x = track, y = listeners)) +
      geom_bar(stat="identity",  fill = "#B90000") +
      coord_flip()+
      theme_few()
  }) 
  
  
  output$map <- renderLeaflet({
    
    observeEvent(input$map_click, { 
      p <- input$map_click
      print(p)
      df = data.frame(lon=c(p[2]), lat=c(p[1]))
      default_country <- coords2country(df)
      default_country
    })
    
    leaflet(geojson) %>% 
    setView(lng = -37.26563, lat = 25.16517, zoom = 2) %>%
      addTiles(urlTemplate = 'http://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png') %>%
      addPolygons(color = "transparent", fillOpacity = 1,
                  highlight = highlightOptions(
                    weight = 3,
                    fillOpacity = 0.5,
                    fillColor = "blue",
                    opacity = 0.5,
                    bringToFront = TRUE,
                    sendToBack = TRUE),
                  label = ~paste0(name))
    
  })
  
  output$playcount_vs_listeners <- renderPlotly({
    artists %>% 
      ggplot(aes(x=playcount, y =listeners, color = playcount)) +
      geom_point() +
      theme_ipsum()
    
  })
}