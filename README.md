#Google Analytics reports for usage metrics

##Install

###Generating csv files from Google Analytics

 - Install Ruby, I'm using ruby 2.0.0p451, but it shouldn't really matter
 - From the checked out directory run ```$ gem install bundler```
 - From the checked out directory run ```$ bundle install``` to install the required dependecies
 - Go to the Google Developer Console https://console.developers.google.com/ as any user who has access to the Google Analytics property
  - Select the 'Lighthouse Analytics' project
  - Go to the APIs & auth section and click credentials
  - Choose an existing OAuth 2.0 client ID, or create a new one
  - Click download JSON
  - Save the file as 'client_secrets.json' in the common/ folder of the checked out project
 - Run one of the reports```$ ruby usage-reports-email-account/usage-email-account.rb```
 - This should open a web browser to let you authenticate using the same credentials as you used to download the client secrets
 - The script should now continue to run and generate a csv file in the folder, e.g 'ruby usage-reports-email-account/usage-email-account.csv'

###Generating R graphs from the csv files

 - Install R, I used RStudio (https://www.rstudio.com/)
 - Make sure R is on the path if you want to automation the generation of reports
 - Install the following R package libaries  (in RStudio it's under Tools->Install Packages...)
  - reshape2
  - ggplot2

##Generating the csv files from Google Analytics
 - Once the install flow above has been completed simply run the ruby file in each folder to generate that report, e.g.
 - ```$ ruby usage-reports-email-account/usage-email-account.rb```
 - The CSV file will be generated in the same directory as the ruby file, e.g 'ruby usage-reports-email-account/usages-email-account.csv'

##Generating the graphs from RSudio
 - From within RStudio open one of the .rmd files in the 'r_reports/' folder
 - Set the R working folder to be the folder containing the .rmd file (ession->Set Working Directory->To Source File Location)
 - Press 'Knit HTML' to generate the HTML graph


##Automation and copying to sharepoint
This uses the Rakefile in the project root

 - Make sure your machine has networked mapped the sharepoint (e.g. open sharepoint in IE, then press 'open in expolorer')
 - If you run ```$ rake clobber``` from the root directory of the project this will delete any csv and html files that have been generated already
 - If you run ```$ rake`` this will run the default task to regenerate the CSVs (from the cached local datastores) and re-draw the graphs for any graphs that are missing.  It will then try to copy them to sharepoint

This system relies on the Rmd and csv files having the same names, and R being on the path


##About the metrics
###Product Page Views
In the last X days (e.g. last week or last 30 days)
Number of page views in the following folders in the Redgate Google Analytics account
 - /products/dlm/dlm-dashboard/
 - /products/dlm/sql-lighthouse/

###Downloads
In the last X days (e.g. last week or last 30 days)
Number of the following events in the Redgate Google Analytics account
 - /products/dlm/dlm-dashboard/
 - /products/dlm/dlm-dashboard/entrypage/
 - /products/dlm/sql-lighthouse/

###Install
In the last X days (e.g. last week or last 30 days)
 - Has visited the dashboard

###New Install
In the last X days (e.g. last week or last 30 days)
 - Has visited the dashboard
 - And we'd never seen them before

###Engaged Team
In the last X days (e.g. last week or last 30 days)
 - Has a database set up
 - Has visited the dashboard at least twice (over all time)
 - Has visited the dashboard in the last 14 days

###New Engaged Team
In the last X days (e.g. last week or last 30 days)
 - Has a database set up
 - Has visited the dashboard at least twice (over all time)
 - Has visited the dashboard in the last 14 days
 - And we'd never seen them before