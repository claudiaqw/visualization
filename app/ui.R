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

slider_colors <- c("white")

ui <- dashboardPage(
  
  # Color de la página
  skin = 'red',
  
  # Titulos
  dashboardHeader(title = 'last.fm',
                  titleWidth = 270,
                  tags$li(a(href = 'https://www.last.fm',
                            img(src = 'golden.png',
                                title = "last.fm Home", height = "30px"),
                            style = "padding-top:10px; padding-bottom:10px;"),
                          class = "dropdown")),
  
  dashboardSidebar(width = 270,
                   sidebarMenu(
                     menuItem('Artists', tabName = 'artists'),
                     menuItem('Tracks', tabName = 'tracks'),
                     menuItem('Albums', tabName = 'albums'),
                     menuItem('World', tabName = 'world')
                   )),
  
  dashboardBody(
    tabItems(
      tabItem(tabName = 'artists',
              fluidRow(h3(strong('Title'))),
              fluidRow(column(width = 12, offset = 2,tags$img(src = 'golden_peque.png'))),
              mainPanel(
                br(),
                fluidRow(tabsetPanel(type = "tab", 
                                     tabPanel(strong("Historia"),
                                              br(), 
                                              p(style="text-align: justify;",
                                                "Los Globo de Oro son galardones..."),
                                     ),
                                     tabPanel(strong('Dashboard'), 
                                              br(),
                                              p(style="text-align: justify;",
                                                "En este Dashboard.." )
                                              
                                             
                                     )),width = 12)
              ),style='width: 1250px; height: 1000px'
      ),
      tabItem(tabName = 'tracks',
              setSliderColor(slider_colors, 1:length(slider_colors)),
              chooseSliderSkin("Flat"),
              fluidRow(h3(strong('Title'))),
              fluidRow(
                column(width = 6, offset = 1, plotlyOutput(outputId = 'barplot'))
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
              mainPanel(br(),
                        p(style="text-align: justify;","..." )
              ),style='width: 1300px; height: 1000px'
      )
    )
  )
)