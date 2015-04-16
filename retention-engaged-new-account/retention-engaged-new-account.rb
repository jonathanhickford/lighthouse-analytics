require 'rubygems'
require 'bundler/setup'

require 'CSV'

require File.join(__dir__, '../common/lighthouse_analytics')

CACHED_DATA_STORE = File.join(__dir__, "datastore.cache")
OUTPUT_CSV = "#{$0}".ext('.csv')

#GA_PROFILE = 'ga:89776902' # Old account id
GA_PROFILE = 'ga:96336725' # New excluding Redgate id


def output_csv(datastore)
  CSV.open(OUTPUT_CSV, "wb") do |csv|
    csv << 	["Period", "First Use In", "Engaged Users"]

    datastore.keys.sort.each do |date_key|
      pretty_date = Date.parse(date_key.split("_")[0]).strftime("%Y-%m-%d")
      datastore[date_key].keys.sort.each do |cohort_key|
        pretty_cohort= Date.parse(cohort_key.split("_")[0]).strftime("%Y-%m-%d")
        csv << [ pretty_date, pretty_cohort,	datastore[date_key][cohort_key]['total_users']]
      end
    end
  end
end



if __FILE__ == $0
	client, analytics = setup_google()
	datastore = setup_datastore()

	start_date_range = Date.new(2015, 1, 11)   # A Sunday
  end_date_range = Date.today
  end_date_range -= end_date_range.wday   # A Sunday

	# Itterate over weeks in report range
  (start_date_range..end_date_range).step(7).each do |start_date|
		end_date = start_date + 6
    print start_date, " - ", end_date, "\n"
    date_key = start_date.strftime("%F") + "_" + end_date.strftime("%F")
    
    datastore[date_key] = Hash.new if !datastore.key?(date_key)

    #Itterate over mothly cohorts in the current month
    (start_date_range..end_date).step(7).each do |cohort_start_date|
      cohort_end_date = cohort_start_date + 6
      cohort_key = cohort_start_date.strftime("%F") + "_" + cohort_end_date.strftime("%F")

      datastore[date_key][cohort_key] = Hash.new if !datastore[date_key].key?(cohort_key)
     
      refreshed = false
      if !datastore[date_key][cohort_key].key?('total_users')  or start_date.cweek == end_date_range.cweek
        refreshed = true
        datastore[date_key][cohort_key]['total_users'] = get_engaged_users_with_cohort(GA_PROFILE, client, analytics, start_date, end_date, cohort_start_date, cohort_end_date)
      end  
      print "\t", cohort_start_date, " - ", cohort_end_date, " ", datastore[date_key][cohort_key]['total_users'] ," #{(refreshed ? 'refreshed' : 'cached')}\n"

    end

	end

	save_datastore(datastore)

	output_csv(datastore)
end


