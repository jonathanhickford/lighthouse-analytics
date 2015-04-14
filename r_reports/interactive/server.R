
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
# 
# http://www.rstudio.com/shiny/
#

library(shiny)
library(reshape2)
library(ggplot2)
usage.wide = read.csv(file.path(".", "data","usage-new-account.csv"))
usage.long = melt(usage.wide, id.vars=c("Period.ending.on"))
usage.long$"Period.ending.on" <- as.Date(usage.wide$"Period.ending.on","%Y-%m-%d")

shinyServer(function(input, output) {
   
  output$plot1 <- renderPlot({
    input$axes
    
    qplot(Period.ending.on, value, data = subset(usage.long,variable %in% input$axes), color = variable, group = variable, geom = c("point", "line"))
    
  })
  
})
