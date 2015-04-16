require 'rubygems'
require 'bundler/setup'

require 'CSV'

require File.join(__dir__, '../common/lighthouse_analytics')

CACHED_DATA_STORE = File.join(__dir__, "datastore.cache")
OUTPUT_CSV = "#{$0}".ext('.csv')

GA_PROFILE_LIGHTHOUSE_OLD = 'ga:89776902' # Old account id
GA_PROFILE_LIGHTHOUSE = 'ga:96336725' # New excluding Redgate id
GA_PROFILE_REDGATE = 'ga:53846' # Redgate - www.redgate.com



def output_csv(datastore)
	CSV.open(OUTPUT_CSV, "wb") do |csv|
		csv <<   ["Date Range", "Product Pageviews", "Downloads", "New Installs", "New Engaged Teams", "Total Installs", "Total Engaged Teams" ]
		
		datastore.keys.sort.each do |date_key|
			csv << [ 
				date_key,
				datastore[date_key]['product pageviews'],
				datastore[date_key]['downloads'],
				datastore[date_key]['new installs'],
				datastore[date_key]['engaged new installs'],
				datastore[date_key]['total installs'],
				datastore[date_key]['engaged installs']
			]
		end
	end

end



if __FILE__ == $0
	client, analytics = setup_google()
	datastore = setup_datastore()

	start_date_range = Date.new(2015, 1, 11)   # A Sunday
  end_date_range = Date.today 
  end_date_range -= end_date_range.wday  # A Sunday
  end_date_range -= 1 # A Saturday

  #puts start_date_range
  #puts end_date_range


	# Itterate over weeks in report range
  (start_date_range..end_date_range).step(7).each do |start_date|
    end_date = start_date + 6

		date_key =  "#{start_date}_#{end_date}"

		#puts date_key

		datastore[date_key] = Hash.new if !datastore.key?(date_key)

		unless datastore[date_key].key?('total installs')
			datastore[date_key]['total installs'] = get_total_users(GA_PROFILE_LIGHTHOUSE, client, analytics, start_date, end_date)
		end

		unless datastore[date_key].key?('new installs')
			datastore[date_key]['new installs'] = get_new_users(GA_PROFILE_LIGHTHOUSE, client, analytics, start_date, end_date)
		end

		unless datastore[date_key].key?('engaged installs')
			datastore[date_key]['engaged installs'] = get_engaged_users(GA_PROFILE_LIGHTHOUSE, client, analytics, start_date, end_date)
		end

		unless datastore[date_key].key?('engaged new installs')
			datastore[date_key]['engaged new installs'] = get_engaged_new_users(GA_PROFILE_LIGHTHOUSE, client, analytics, start_date, end_date)
		end

		# From Redgate account
		unless datastore[date_key].key?('downloads')
			datastore[date_key]['downloads'] = get_total_downloads(GA_PROFILE_REDGATE, client, analytics, start_date, end_date)
		end

		unless datastore[date_key].key?('product pageviews')
			datastore[date_key]['product pageviews'] = get_total_product_page_views(GA_PROFILE_REDGATE, client, analytics, start_date, end_date)
		end

		
		puts date_key +
			" " + datastore[date_key]['total installs'].to_s +
			" " + datastore[date_key]['new installs'].to_s + 
			" " + datastore[date_key]['engaged installs'].to_s + 
			" " + datastore[date_key]['engaged new installs'].to_s + 
			" " + datastore[date_key]['downloads'].to_s +
			" " + datastore[date_key]['product pageviews'].to_s

	end

	save_datastore(datastore)

	output_csv(datastore)
end


