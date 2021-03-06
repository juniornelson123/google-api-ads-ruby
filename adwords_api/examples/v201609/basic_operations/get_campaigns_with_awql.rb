#!/usr/bin/env ruby
# Encoding: utf-8
#
# Copyright:: Copyright 2012, Google Inc. All Rights Reserved.
#
# License:: Licensed under the Apache License, Version 2.0 (the "License");
#           you may not use this file except in compliance with the License.
#           You may obtain a copy of the License at
#
#           http://www.apache.org/licenses/LICENSE-2.0
#
#           Unless required by applicable law or agreed to in writing, software
#           distributed under the License is distributed on an "AS IS" BASIS,
#           WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
#           implied.
#           See the License for the specific language governing permissions and
#           limitations under the License.
#
# This example illustrates how to retrieve all the campaigns for an account with
# AWQL.

require 'adwords_api'

def get_campaigns_with_awql()
  # AdwordsApi::Api will read a config file from ENV['HOME']/adwords_api.yml
  # when called without parameters.
  adwords = AdwordsApi::Api.new

  # To enable logging of SOAP requests, set the log_level value to 'DEBUG' in
  # the configuration file or provide your own logger:
  # adwords.logger = Logger.new('adwords_xml.log')

  campaign_srv = adwords.service(:CampaignService, API_VERSION)

  # Get all the campaigns for this account.
  query = 'SELECT Id, Name, Status ORDER BY Name'

  # Set initial values.
  offset, page = 0, {}

  begin
    page_query = query + ' LIMIT %d,%d' % [offset, PAGE_SIZE]
    page = campaign_srv.query(page_query)
    if page[:entries]
      page[:entries].each do |campaign|
        puts "Campaign ID %d, name '%s' and status '%s'" %
            [campaign[:id], campaign[:name], campaign[:status]]
      end
      # Increment values to request the next page.
      offset += PAGE_SIZE
    end
  end while page[:total_num_entries] > offset

  if page.include?(:total_num_entries)
    puts "\tTotal number of campaigns found: %d." % page[:total_num_entries]
  end
end

if __FILE__ == $0
  API_VERSION = :v201609
  PAGE_SIZE = 500

  begin
    get_campaigns_with_awql()

  # Authorization error.
  rescue AdsCommon::Errors::OAuth2VerificationRequired => e
    puts "Authorization credentials are not valid. Edit adwords_api.yml for " +
        "OAuth2 client ID and secret and run misc/setup_oauth2.rb example " +
        "to retrieve and store OAuth2 tokens."
    puts "See this wiki page for more details:\n\n  " +
        'https://github.com/googleads/google-api-ads-ruby/wiki/OAuth2'

  # HTTP errors.
  rescue AdsCommon::Errors::HttpError => e
    puts 'HTTP Error: %s' % e

  # API errors.
  rescue AdwordsApi::Errors::ApiException => e
    puts 'Message: %s' % e.message
    puts 'Errors:'
    e.errors.each_with_index do |error, index|
      puts "\tError [%d]:" % (index + 1)
      error.each do |field, value|
        puts "\t\t%s: %s" % [field, value]
      end
    end
  end
end
