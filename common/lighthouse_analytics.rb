require 'google/api_client'
require 'google/api_client/client_secrets'
require 'google/api_client/auth/file_storage'
require 'google/api_client/auth/installed_app'
require 'rake/ext/string'

API_VERSION = 'v3'
CACHED_API_FILE = File.dirname(__FILE__) + "/analytics-#{API_VERSION}.cache"
CREDENTIAL_STORE_FILE = File.dirname(__FILE__) + "/lighthouse_analytics-oauth2.json"
CLIENT_SECRETS = File.dirname(__FILE__) + '/client_secrets.json'

$stdout.sync = true

def setup_google()

  client = Google::APIClient.new(:application_name => 'Lighthouse GA Reports', :application_version => '0.0.1')

  # FileStorage stores auth credentials in a file, so they survive multiple runs
  # of the application. This avoids prompting the user for authorization every
  # time the access token expires, by remembering the refresh token.
  # Note: FileStorage is not suitable for multi-user applications.
  file_storage = Google::APIClient::FileStorage.new(CREDENTIAL_STORE_FILE)
  
  if file_storage.authorization.nil?
    client_secrets = Google::APIClient::ClientSecrets.load(CLIENT_SECRETS)
    # The InstalledAppFlow is a helper class to handle the OAuth 2.0 installed
    # application flow, which ties in with FileStorage to store credentials
    # between runs.
    flow = Google::APIClient::InstalledAppFlow.new(
    :client_id => client_secrets.client_id,
    :client_secret => client_secrets.client_secret,
    :scope => ['https://www.googleapis.com/auth/analytics.readonly']
    )
    client.authorization = flow.authorize(file_storage)
  else
    client.authorization = file_storage.authorization
  end


  analytics = nil
  # Load cached discovered API, if it exists. This prevents retrieving the
  # discovery document on every run, saving a round-trip to API servers.
  if File.exists? CACHED_API_FILE
    File.open(CACHED_API_FILE) do |file|
      analytics = Marshal.load(file)
    end
  else
    urlshortener = client.discovered_api('urlshortener')
    analytics = client.discovered_api('analytics', API_VERSION)
    File.open(CACHED_API_FILE, 'w') do |file|
      Marshal.dump(analytics, file)
    end
  end

  return client, analytics
end

def setup_datastore()
  datastore = nil

  if File.exists? CACHED_DATA_STORE
    File.open(CACHED_DATA_STORE) do |file|
      datastore = Marshal.load(file)
    end
  else
    datastore = Hash.new 
    save_datastore(datastore)
  end

  datastore
end

def save_datastore(datastore)
  File.open(CACHED_DATA_STORE, 'w') do |file|
    Marshal.dump(datastore, file)
  end
end


def get_total_users(profile, client, analytics, start_date, end_date)
  result = client.execute(
    :api_method => analytics.data.ga.get,
    :parameters => {
      'ids' => profile,
      'start-date' => start_date.strftime("%F"),
      'end-date' => end_date.strftime("%F"),
      'metrics' => 'ga:users',
      'fields' => 'totalsForAllResults'
    }
  )
  result.data['totalsForAllResults']['ga:users'] if result.data['totalsForAllResults']
end

def get_new_users(profile, client, analytics, start_date, end_date)
  result = client.execute(
    :api_method => analytics.data.ga.get,
    :parameters => {
      'ids' => profile,
      'start-date' => start_date.strftime("%F"),
      'end-date' => end_date.strftime("%F"),
      'metrics' => 'ga:newUsers',
      'fields' => 'totalsForAllResults'
    }
  )
  result.data['totalsForAllResults']['ga:newUsers'] if result.data['totalsForAllResults']
end


def get_engaged_users(profile, client, analytics, start_date, end_date)
  result = client.execute(
    :api_method => analytics.data.ga.get,
    :parameters => {
      'ids' => profile,
      'start-date' => start_date.strftime("%F"),
      'end-date' => end_date.strftime("%F"),
      'metrics' => 'ga:users',
      'fields' => 'totalsForAllResults',
      'segment' => "users::condition::ga:dimension2!=0;ga:sessionCount>=2;ga:daysSinceLastSession<=14"
    }
  )
  result.data['totalsForAllResults']['ga:users'] if result.data['totalsForAllResults']
end

def get_engaged_new_users(profile, client, analytics, start_date, end_date)
  result = client.execute(
    :api_method => analytics.data.ga.get,
    :parameters => {
      'ids' => profile,
      'start-date' => start_date.strftime("%F"),
      'end-date' => end_date.strftime("%F"),
      'metrics' => 'ga:newUsers',
      'fields' => 'totalsForAllResults',
      'segment' => "users::condition::ga:dimension2!=0;ga:sessionCount>=2;ga:daysSinceLastSession<=14"
    }
  )
  result.data['totalsForAllResults']['ga:newUsers'] if result.data['totalsForAllResults']
end

def get_retained_users(profile, client, analytics, start_date, end_date)
  result = client.execute(
    :api_method => analytics.data.ga.get,
    :parameters => {
      'ids' => profile,
      'start-date' => start_date.strftime("%F"),
      'end-date' => end_date.strftime("%F"),
      'metrics' => 'ga:users',
      'fields' => 'totalsForAllResults',
      'segment' => "users::sequence::!^ga:sessionCount==1;dateOfSession<>#{(start_date).strftime("%F")}_#{end_date.strftime("%F")}"
    }
  )
  result.data['totalsForAllResults']['ga:users'] if result.data['totalsForAllResults']
end



def get_engaged_users_with_cohort(profile, client, analytics, start_date, end_date, cohort_start_date, cohort_end_date)
  result = client.execute(
    :api_method => analytics.data.ga.get,
    :parameters => {
      'ids' => profile,
      'start-date' => start_date.strftime("%F"),
      'end-date' => end_date.strftime("%F"),
      'metrics' => 'ga:users',
      'fields' => 'totalsForAllResults',      
      'segment' => "users::condition::ga:dimension2!=0;ga:daysSinceLastSession<=14;ga:sessionCount==1;dateOfSession<>#{cohort_start_date.strftime("%F")}_#{cohort_end_date.strftime("%F")}"
    }
  )
  result.data['totalsForAllResults']['ga:users'] if result.data['totalsForAllResults']
end


def get_total_downloads(profile, client, analytics, start_date, end_date)
  download_events = %w(/products/dlm/dlm-dashboard/ /products/dlm/dlm-dashboard/entrypage/ /products/dlm/sql-lighthouse/)
  download_events.map! { |url| "ga:eventLabel==" + url}
  filters = download_events.join(',')

  result = client.execute(
    :api_method => analytics.data.ga.get,
    :parameters => {
      'ids' => profile,
      'start-date' => start_date.strftime("%F"),
      'end-date' => end_date.strftime("%F"),
      'metrics' => 'ga:totalEvents',
      'filters' => filters,
      'fields' => 'totalsForAllResults'
    }
  )
  result.data['totalsForAllResults']['ga:totalEvents'] if result.data['totalsForAllResults']
end




def get_total_product_page_views(profile, client, analytics, start_date, end_date)
  result = client.execute(
    :api_method => analytics.data.ga.get,
    :parameters => {
      'ids' => profile,
      'start-date' => start_date.strftime("%F"),
      'end-date' => end_date.strftime("%F"),
      'metrics' => 'ga:pageviews',
      'filters' => 'ga:pagePathLevel1==/products/;ga:pagePathLevel2==/dlm/;ga:pagePathLevel3==/dlm-dashboard/,ga:pagePathLevel3==/sql-lighthouse/', # products AND dlm AND (dlm-dashboard OR sql-lighthouse)
      'fields' => 'totalsForAllResults'
    }
  )
  result.data['totalsForAllResults']['ga:pageviews'] if result.data['totalsForAllResults']
end






# Deprecated
def get_active_users(profile, client, analytics, start_date, end_date)
  result = client.execute(
    :api_method => analytics.data.ga.get,
    :parameters => {
      'ids' => profile,
      'start-date' => start_date.strftime("%F"),
      'end-date' => end_date.strftime("%F"),
      'metrics' => 'ga:users',
      'fields' => 'totalsForAllResults',
      'filters' => 'ga:dimension2!=0'
    }
  )
  result.data['totalsForAllResults']['ga:users']
end

# Deprecated
def get_new_active_users(profile, client, analytics, start_date, end_date)
  result = client.execute(
    :api_method => analytics.data.ga.get,
    :parameters => {
      'ids' => profile,
      'start-date' => start_date.strftime("%F"),
      'end-date' => end_date.strftime("%F"),
      'metrics' => 'ga:newUsers',
      'fields' => 'totalsForAllResults',
      'filters' => 'ga:dimension2!=0'
    }
  )
  result.data['totalsForAllResults']['ga:newUsers']
end
