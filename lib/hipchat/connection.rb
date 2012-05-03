require 'faraday'

module HipChat
  module Connection
    def self.create options
      options[:adapter] ||= :net_http
      Faraday.new(:url => 'https://api.hipchat.com/v1/rooms') do |builder|
        builder.request  :url_encoded
        builder.response :logger if options[:logging]
        builder.adapter  options[:adapter]
      end
    end
  end
end
