library(ggplot2)
library(dplyr)
library(ggthemes)
library(hrbrthemes)


library(leaflet)
library(sp)
library(maps)
library(maptools)
library(lubridate)

artists <- read.csv(file = './data/artists.csv')
tracks <- read.csv('./data/tracks.csv')

serie.df <- read.csv(file='./data/artist_by_user_serie.csv') 
serie.df$date <- as.Date(serie.df$date)


top_ten <-artists %>% 
  arrange(desc(listeners)) %>% 
  top_n(20)
  

top_ten %>% 
  ggplot(aes(x = name, y = listeners, fill)) +
  geom_bar(stat="identity", fill = "#B90000") +
  coord_flip() +
  theme_few()
#  theme_calc()


world <- map("world", fill=TRUE, plot=FALSE)
world_map <- map2SpatialPolygons(world, sub(":.*$", "", world$names))
world_map <- SpatialPolygonsDataFrame(world_map,
                                      data.frame(country=names(world_map), 
                                                 stringsAsFactors=FALSE), 
                                      FALSE)

cnt <- c("Russia", "Afghanistan", "Albania", "Algeria", "Argentina", "Armenia",
         "Azerbaijan", "Bangladesh", "Belarus")

target <- subset(world_map, country %in% cnt)

leaflet(target) %>% 
  addTiles() %>% 
  addPolygons(weight=1)


library(rgdal)
countries <- readOGR("data/countries.geo.json")
leaflet(countries) %>% 
  addProviderTiles(providers$Stamen.TonerLite,
                   options = providerTileOptions(noWrap = TRUE)) %>% 
  addTiles() %>% 
  addPolygons(color = "transparent", fillOpacity = 1,
              highlight = highlightOptions(
                weight = 3,
                fillOpacity = 0.5,
                fillColor = "blue",
                opacity = 0.5,
                bringToFront = TRUE,
                sendToBack = TRUE),
     label = ~paste0(name))


geojson <- readOGR("data/countries.geo.json")
leaflet(geojson) %>% 
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


top_artists <- read.csv(file='./data/top_artists_per_country.csv') 
default_country <-'Spain'

top_artists %>% 
  filter(country == default_country) %>% 
  arrange(rank) %>% 
  ggplot(aes(x = artist, y = listeners)) +
  geom_bar(stat="identity",  fill = "#B90000") +
  coord_flip()+
  theme_few()


top_ten_tracks <-tracks %>% 
  arrange(desc(playcount)) %>% 
  top_n(20)


top_ten_tracks %>% ggplot() +
  geom_bar(aes(x=name, y=playcount), stat="identity", fill = "#B90000") +
  geom_bar(aes(x=name, y=listeners), stat="identity", fill = "blue") +
  coord_flip() +
  theme_few()

selected_artist <- 'The Weeknd' 

artist.filtered <- serie.df %>% 
  filter(artist == selected_artist, year(date) == 2021) %>% 
  group_by(date) %>% 
  summarise(count = n())

artist.filtered %>% 
  ggplot(aes(x=date, y=count)) +
  geom_line(color="#69b3a2") +
  xlab("") +
  theme_ipsum()
  

artists %>% 
  ggplot(aes(x=playcount, y =listeners, color = playcount)) +
  geom_point() +
  theme_ipsum()


top_artists %>% 
  filter(country == 'United States of America') %>% 
  arrange(rank) %>% 
  ggplot(aes(x = artist, y = listeners)) +
  geom_bar(stat="identity",  fill = "#B90000") +
  coord_flip()+
  theme_few()


