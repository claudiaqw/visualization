library(shiny)
library(ggplot2)
library(rgdal)
library(leaflet)
library(rgdal)
library(sp)
library(rworldmap)
library(dplyr)
library(bubbles)
library(ggthemes)
library(hrbrthemes)
library(rsconnect)


function(input, output) {
  
  artists <- read.csv(file = './data/artists.csv')
  tracks <- read.csv(file = './data/tracks.csv')
  
  top_artists <- read.csv(file='./data/top_artists_per_country.csv')
  top_tracks <- read.csv(file='./data/top_tracks_per_country.csv')
  
  serie.df <- read.csv(file='./data/reduced_serie.csv') 
  serie.df$date <- as.Date(serie.df$date)
  
  geojson <- readOGR("data/countries.geo.json")
  
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
  
  ## Home ##
  output$artists <- renderValueBox({
    artists_count = length(unique(artists$name))
    
    valueBox(
      value = formatC(artists_count, digits = 0, format = "f"),
      subtitle = "Artists",
      icon = icon("podcast"),
      color = "aqua"
    )
  })
  
  output$tracks <- renderValueBox({
    tracks_count = length(unique(tracks$name))
    
    valueBox(
      value = formatC(tracks_count, digits = 0, format = "f"),
      subtitle = "Tracks",
      icon = icon("music"),
      color = "yellow"
    )
  })
  
  output$users <- renderValueBox({
    users_count = 25000
    
    valueBox(
      value = formatC(users_count, digits = 0, format = "f"),
      subtitle = "Unique users",
      icon = icon("users"),
      color = "red"
    )
  })
  
  output$myImage <- renderImage({
    # A temp file to save the output.
    # This file will be removed later by renderImage
    outfile <- tempfile(fileext = './images/wave.jpg')
    
    png(outfile, width = 400, height = 300)
    hist(rnorm(input$obs), main = "Generated in renderImage()")
    dev.off()
    
    # Return a list containing the filename
    list(src = outfile,
         contentType = 'image/png',
         width = 400,
         height = 300,
         alt = "This is alternate text")
  }, deleteFile = TRUE)
  
  
  
  # ---------------------------------------------------------------------------
  
  ## Artists ##
  
  output$bubble_artist <- renderBubbles({
    
    df <-artists %>% 
      arrange(desc(playcount)) %>%
      select("Artist" = name, "Playcount" = playcount) %>%
      head(20)
    
    bubbles(df$Playcount, df$Artist, key = df$Artist)
  })
  
  output$table_artist <- renderTable({
    
    table <-artists %>% 
      arrange(desc(playcount)) %>% 
      select("Artist" = name, "Playcount" = playcount) %>% 
      head(20)
    
  })
  
  output$playcount_vs_listeners <- renderPlotly({
    artists %>% 
      ggplot(aes(x=playcount, y =listeners, color = playcount)) +
      geom_point() +
      theme_ipsum()
    
  })
  
  output$artist_serie <- renderPlotly({
    
    print(class(input$dateRange))
    print(input$dateRange)
    #min_date <- input$dateRange[1]
    #max_date <- input$dateRange[2]
    
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
  
  output$barplot <-  renderPlotly({
    top_ten <-artists %>% 
      arrange(desc(listeners)) %>% 
      head(20)
    
    top_ten %>% 
      ggplot(aes(x = name, y = listeners)) +
      geom_bar(stat="identity",  fill = "#B90000") +
      coord_flip()+
      theme_ipsum()
  })
  
  
  
  # ---------------------------------------------------------------------------
  
  ## Tracks ##
  
  output$track_barplot <-renderPlotly({
    top_ten_tracks <-tracks %>% 
      arrange(desc(playcount)) %>% 
      head(40)
    
    top_ten_tracks %>% ggplot() +
      geom_bar(aes(x=name, y=playcount), stat="identity", fill = "#B90000") +
      geom_bar(aes(x=name, y=listeners), stat="identity", fill = "blue") +
      coord_flip() +
      theme_few()
  })
  
  output$scatter <- renderPlotly({
    
    tracks.tags <- read.csv(file='./data/tracks_tags.csv')
    
    tracks.tags %>% 
      ggplot(aes(x=track, y=tag)) +
      geom_point(aes(size=tag_count, color = playcount), alpha = 0.7) +
      theme(axis.text.x = element_text(angle = 90))
  })
  
  
  
  # ---------------------------------------------------------------------------
  
  ## Albums ##
  
  output$bubble_album <- renderBubbles({
    
    album_filter <- serie.df %>%
      filter(year(date) == input$year, album != '') %>%
      group_by(album) %>%
      summarise(count = n(), artist = first(artist)) %>% 
      arrange(desc(count)) %>% 
      head(40)
    
    bubbles(album_filter$count, album_filter$album, key = album_filter$Artist)
    
  })
  
  output$album_year <- renderPlotly({
    
    album_filter <- serie.df %>%
      filter(year(date) == input$year, album != '') %>%
      group_by(album) %>%
      summarise(count = n(), artist = first(artist)) %>% 
      arrange(desc(count)) %>% 
      head(40)
    
    album_filter %>% 
      ggplot(aes(x = album, y = count)) +
      geom_bar(stat="identity", fill = "#B90000") +
      coord_flip() +
      theme_few()
  })
  
  
  
  
  # ---------------------------------------------------------------------------
  
  ## World ##
  
  output$top_artists_by_country_header <- renderText({
    p <- input$map_click
    
    if(is.null(input$map_click))
    {
      p <- c(40.44695, -1.582031)
    }
    
    df = data.frame(lon=c(p[2]), lat=c(p[1]))
    default_country <- coords2country(df)
    
    paste0("Top artists in ", default_country)
  })
  
  output$top_tracks_by_country_header <- renderText({
    p <- input$map_click
    
    if(is.null(input$map_click))
    {
      p <- c(40.44695, -1.582031)
    }
    
    df = data.frame(lon=c(p[2]), lat=c(p[1]))
    default_country <- coords2country(df)
    
    paste0("Top tracks in ", default_country)
  })
  
  output$top_artists_by_country <- renderPlotly({
    p <- input$map_click
    
    if(is.null(input$map_click))
    {
      p <- c(40.44695, -1.582031)
    }
    
    df = data.frame(lon=c(p[2]), lat=c(p[1]))
    default_country <- coords2country(df)
    
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
    
    if(is.null(input$map_click))
    {
      p <- c(40.44695, -1.582031)
    }
    
    df = data.frame(lon=c(p[2]), lat=c(p[1]))
    default_country <- coords2country(df)
    
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
  
  
}