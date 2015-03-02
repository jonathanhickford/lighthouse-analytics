
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
# 
# http://www.rstudio.com/shiny/
#

library(shiny)

shinyUI(fluidPage(
  titlePanel("title panel"),
  
  sidebarLayout(
    sidebarPanel(
      checkboxGroupInput("axes", 
                         label = h3("Checkbox group"), 
                         choices = list("Total.teams.in.last.30.days" = "Total.teams.in.last.30.days", 
                                        "New.teams.in.last.30.days" = "New.teams.in.last.30.days", 
                                        "Engaged.teams.in.last.30.days" = "Engaged.teams.in.last.30.days",
                                        "Retained.teams.in.last.30.days" = "Retained.teams.in.last.30.days"
                                        ),
                         selected = c("Total.teams.in.last.30.days", "Engaged.teams.in.last.30.days"))
      ),
    mainPanel(
      plotOutput("plot1")
      )
  )
))
