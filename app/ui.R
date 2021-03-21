library(rsconnect)
library(ggplot2)
library(data.table)
library(shiny)
library(shinydashboard)
library(shinyWidgets)
library(plotly)
library(tidyr)
library(dplyr)
library(stringr)
library(png)
library(grid)
library(ggimage)
library(cowplot)
library(magick)
library(leaflet)
library(bubbles)

serie.df <- read.csv(file='./data/reduced_serie.csv') 
artists = unique(serie.df$artist)
dates <- unique(serie.df$date)
min_date <- min(dates)
max_date <- max(dates)

slider_colors <- c("red")


ui <- dashboardPage(
  skin = 'red',
  dashboardHeader(title = 'last.fm',
                  titleWidth = 300,
                  tags$li(a(href = 'https://www.last.fm',
                            tags$img(src = 'lastfm_icon.png',
                                title = "last.fm Home", height = "30px"),
                            style = "padding-top:10px; padding-bottom:10px;"),
                          class = "dropdown")),
  
  dashboardSidebar(width = 300,
                   sidebarMenu(
                     menuItem('Home', tabName = 'home', icon=icon("home", lib="font-awesome")),
                     menuItem('Artists', tabName = 'artists', icon = icon("user")),
                     menuItem('Tracks', tabName = 'tracks', icon = icon("music")),
                     menuItem('Albums', tabName = 'albums', icon=icon("record-vinyl")),
                     menuItem('World', tabName = 'world', icon = icon("globe", lib = "font-awesome"))
                   )),
  
  dashboardBody(
    tabItems(
      tabItem(tabName = 'home',
              fluidRow(
                valueBoxOutput("artists"),
                valueBoxOutput("tracks"),
                valueBoxOutput("users")
              ),
              mainPanel(
                img(src='wave.jpg', align = "center")
              ),
              style='width: 100%; height: 100%'),
      tabItem(tabName = 'artists',
                fluidRow(h2(strong('Artists'))),
                mainPanel(
                  br(),
                  fluidRow(
                    tabsetPanel(type = "tab", 
                                     tabPanel(
                                       fluidRow(
                                         offset = 1,
                                         strong("Most popular artists")),
                                       br(), 
                                       p(style="text-align: justify;", 
                                         "En este dashboards se muestra la evolución en el tiempo..."),
                                       fluidRow(
                                         box(
                                           width = 8, status = "info", solidHeader = FALSE,
                                           bubblesOutput("bubble_artist", width = "100%", height = 700)),
                                         box(
                                           width = 4, status = "info",
                                           title = "Top 20 artist",
                                           tableOutput("table_artist")))),
                                     tabPanel(
                                       strong("Playcount vs. Listeners"),
                                       br(), 
                                       p(style="text-align: justify;", 
                                         "En este dashboards se muestra la evolución en el tiempo..."),
                                       fluidRow(
                                         column(
                                           width = 12,
                                           offset = 1,
                                           plotlyOutput(outputId = "playcount_vs_listeners")
                                         ))),
                                     tabPanel(strong('Series'), 
                                              br(),
                                              p(style="text-align: justify;",
                                                "En este Dashboard.." ),
                                              fluidRow(
                                                column(width = 2.2, 
                                                       offset = 1, 
                                                       selectInput(inputId ="artist_name", 
                                                                   label = "Select an artist: ",
                                                                   choices = artists,
                                                                   selected = "selected_artist")
                                                       #dateRangeInput('dateRange',
                                                        #             label = 'Select a date range:',
                                                         #            start = min_date, end = max_date)
                                                       )),
                                              fluidRow(
                                                column(
                                                  width=12,
                                                  offset = 1,
                                                  plotlyOutput(outputId = "artist_serie")
                                                )))),
                           width = 12)
              ),style='width: 100%; height: 100%'),
      tabItem(tabName = 'tracks',
              fluidRow(h3(strong('Tracks'))),
              mainPanel(
                br(),
                fluidRow(
                  tabsetPanel(type="tab",
                              tabPanel(
                                strong("Most popular tracks"),
                                br(),
                                fluidRow(
                                  column(
                                    width = 12,
                                    offset = 1, 
                                    plotlyOutput(outputId = 'track_barplot', width = "100%", height = "100%")))),
                              tabPanel(
                                strong("Tracks per category"),
                                br(),
                                fluidRow(
                                  column(
                                    width = 12,
                                    offset = 1,
                                    plotlyOutput(outputId = "scatter", width = "100%", height = "150%")
                                  )),
                                style='width: 100%; height: 150%')))),
              style='width: 100%; height: 100%'
      ),
      tabItem(tabName = 'albums',
              chooseSliderSkin("Flat"),
              setSliderColor(slider_colors, 1:length(slider_colors)),
              fluidRow(
                column(
                  width = 5,
                  offset = 1,
                  h3(strong('Albums')))),
              mainPanel(
                br(),
                p("..."),
                fluidRow(
                  column(
                    width=5,
                    offset=1,
                    sliderInput(inputId = 'year',
                                label = 'Select year:',
                                min = 2018, max = 2021, value = 2021,
                                width = '100%'))),
                fluidRow(
                  box(
                    width = 6, status = "info", solidHeader = FALSE,
                    bubblesOutput("bubble_album", width = "100%", height = 500)),
                  box(
                    width = 6, status = "info", solidHeader = FALSE,
                    plotlyOutput(outputId = "album_year", height = "100%")
                    
                  )
                ),
                style='width: 100%; height: 100%'
              ),
              style='width: 100%; height: 100%'
      ),
      tabItem(tabName = 'world',
              fluidRow(
                h3(strong('Top artists/tracks per country'))
                ),
              fluidPage(
                leafletOutput("map", width = "100%", height = 500),
                br(), br(),
                h3(textOutput(outputId = "top_artists_by_country_header")),
                plotlyOutput(outputId = "top_artists_by_country"),
                br(), br(),
                h3(textOutput(outputId = "top_tracks_by_country_header")),
                plotlyOutput(outputId = "top_tracks_by_country")
                ),
              mainPanel(br(),
                        p( )
              ),style='width: 100%; height: 200%'
      )
    )
  )
)