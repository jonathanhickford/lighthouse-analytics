require 'rubygems'
require 'bundler/setup'

require 'CSV'

require File.join(__dir__, '../common/lighthouse_analytics')

CACHED_DATA_STORE = File.join(__dir__, "datastore.cache")
OUTPUT_CSV = "#{$0}".ext('.csv')

#GA_PROFILE = 'ga:89776902' # Old account id
GA_PROFILE = 'ga:96336725' # New excluding Redgate id

ROLLING_WINDOW=29

def output_csv(datastore)
	CSV.open(OUTPUT_CSV, "wb") do |csv|
		csv <<   ["Period ending on", "Total teams in last 30 days", "New teams in last 30 days", "Engaged teams in last 30 days", "Retained teams in last 30 days"]
		
		datastore.keys.sort.each do |end_date|
			csv << [ end_date, 

				datastore[end_date]['total in last 30 days'],
				datastore[end_date]['new in last 30 days'],
				datastore[end_date]['engaged in last 30 days'],
				datastore[end_date]['retained in last 30 days']

			]
		end
	end

end



if __FILE__ == $0
	client, analytics = setup_google()
	datastore = setup_datastore()

	today = Date.today
  start = Date.new(2015,1,14)

	(start..today-1).each do |end_date|
		datastore[end_date] = Hash.new if !datastore.key?(end_date)

	
		unless datastore[end_date].key?('total in last 30 days')
			datastore[end_date]['total in last 30 days'] = get_total_users(GA_PROFILE, client, analytics, end_date-ROLLING_WINDOW, end_date)
		end

			
		unless datastore[end_date].key?('new in last 30 days')
			datastore[end_date]['new in last 30 days'] = get_new_users(GA_PROFILE, client, analytics, end_date-ROLLING_WINDOW, end_date)
		end

	
		unless datastore[end_date].key?('engaged in last 30 days')
			datastore[end_date]['engaged in last 30 days'] = get_engaged_users(GA_PROFILE, client, analytics, end_date-ROLLING_WINDOW, end_date)
		end

		unless datastore[end_date].key?('retained in last 30 days')
			datastore[end_date]['retained in last 30 days'] = get_retained_users(GA_PROFILE, client, analytics, end_date-ROLLING_WINDOW, end_date)
		end

		puts end_date.to_s +
			" " + datastore[end_date]['total in last 30 days'].to_s +
			" " + datastore[end_date]['new in last 30 days'].to_s + 
			" " + datastore[end_date]['engaged in last 30 days'].to_s +
			" " + datastore[end_date]['retained in last 30 days'].to_s
	end

	save_datastore(datastore)

	output_csv(datastore)
end


