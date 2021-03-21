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

slider_colors <- c("white")

serie.df <- read.csv(file='./data/artist_by_user_serie.csv') 

artists = unique(serie.df$artist)


ui <- dashboardPage(
  skin = 'red',
  dashboardHeader(title = 'last.fm',
                  titleWidth = 300,
                  tags$li(a(href = 'https://www.last.fm',
                            img(src = 'lastfm_icon.png',
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
              fluidRow(h1('Home')),
              mainPanel()),
      tabItem(tabName = 'artists',
                fluidRow(h2(strong('Artists'))),
                mainPanel(
                  br(),
                  fluidRow(
                    tabsetPanel(type = "tab", 
                                     tabPanel(
                                       strong("Most popular artists"),
                                       br(), 
                                       p(style="text-align: justify;", 
                                         "En este dashboards se muestra la evolución en el tiempo..."),
                                       fluidRow(
                                         column(
                                           width = 12,
                                           offset = 1, 
                                           plotlyOutput(outputId = 'barplot')))),
                                     tabPanel(
                                       strong("Playcount vs. Listeners"),
                                       fluidRow(
                                         column(
                                           width = 12,
                                           offset = 1,
                                           plotlyOutput(outputId = "playcount_vs_listeners")
                                         )
                                       )
                                     ),
                                     tabPanel(strong('Series'), 
                                              br(),
                                              p(style="text-align: justify;",
                                                "En este Dashboard.." ),
                                              fluidRow(
                                                column(width = 2.2, 
                                                       offset = 1, 
                                                       selectInput(inputId ="artist_name", 
                                                                   label = "Escoge un artista: ",
                                                                   choices = artists,
                                                                   selected = "selected_artist"))),
                                              fluidRow(
                                                column(
                                                  width=12,
                                                  offset = 1,
                                                  plotlyOutput(outputId = "artist_serie")
                                                )))),
                           width = 12)
              ),style='width: 1300px; height: 1000px'),
      tabItem(tabName = 'tracks',
              chooseSliderSkin("Flat"),
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
                                    plotlyOutput(outputId = 'track_barplot')
                                  )
                                )
                              ),
                              tabPanel(
                                strong("Top 20")
                                )
                  )
                )
              ),
              style='width: 1300px; height: 1000px'
      ),
      tabItem(tabName = 'albums',
              chooseSliderSkin("Flat"),
              fluidRow(h3(strong('Title'))),
              mainPanel(br(),
                        p("...")
              ),style='width: 1300px; height: 1000px'
      ),
      tabItem(tabName = 'world',                  
              chooseSliderSkin("Flat"),
              fluidRow(h3(strong('Title'))),
              fluidPage(
                leafletOutput("map", width = "100%", height = 500),
                plotlyOutput(outputId = "top_artists_by_country"),
                plotlyOutput(outputId = "top_tracks_by_country")
                ),
              mainPanel(br(),
                        #fluidRow(
                        #  column(width = 12,
                        #         offset = 1,
                        #         plotlyOutput(outputId = 'top_artists_by_country'))),
                        p(style="text-align: justify;","..." )
              ),style='width: 1300px; height: 1000px'
      )
    )
  )
)