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
  start_range = Date.new(2014,11,1)
  end_range = Date.new(today.year, today.month, 1) - 1

  #puts start_range
  #puts end_range


	(start_range..end_range).select {|d| d.day == 1}.each do |start_date|

		end_date = Date.new(start_date.year,start_date.month,-1)
		date_key =  "#{start_date}_#{end_date}"

		#puts date_key

		datastore[date_key] = Hash.new if !datastore.key?(date_key)

		unless datastore[date_key].key?('total installs')
			datastore[date_key]['total installs'] = get_total_users(GA_PROFILE, client, analytics, start_date, end_date)
		end

		unless datastore[date_key].key?('new installs')
			datastore[date_key]['new installs'] = get_new_users(GA_PROFILE, client, analytics, start_date, end_date)
		end

		unless datastore[date_key].key?('engaged installs')
			datastore[date_key]['engaged installs'] = get_engaged_users(GA_PROFILE, client, analytics, start_date, end_date)
		end

				unless datastore[date_key].key?('engaged new installs')
			datastore[date_key]['engaged new installs'] = get_engaged_new_users(GA_PROFILE, client, analytics, start_date, end_date)
		end

	

		puts date_key +
			" " + datastore[date_key]['total installs'].to_s +
			" " + datastore[date_key]['new installs'].to_s + 
			" " + datastore[date_key]['engaged installs'].to_s + 
			" " + datastore[date_key]['engaged new installs'].to_s

	end

	#save_datastore(datastore)

	#output_csv(datastore)
end


