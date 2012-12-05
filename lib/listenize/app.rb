require 'sinatra'
require 'sprockets'
require 'json'

module Listenize
  class App < Sinatra::Base
    set :root, File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'app'))
    set :components, File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'components'))
    set :server, :thin

    set :audiences, []
    set :channels, []

    set(:sprockets, Sprockets::Environment.new.tap { |env|
      env.append_path "#{root}/javascripts"
      env.append_path "#{root}/stylesheets"
      env.append_path components
    })

    get '/' do
      haml :index
    end

    get '/api/stream' do
      headers 'Cache-Control' => 'no-cache'
      content_type 'text/event-stream'
      stream(:keep_open) do |out|
        out.callback do
          settings.audiences.delete out
        end

        out << "event: channels\n"
        out << "data: #{settings.channels.to_json}\n\n"
        settings.audiences << out
      end
    end

    post '/api/bulk' do
      content_type :json

      request.body.rewind
      begin
        json = request.body.read
        payloads = JSON.parse(json)
        payloads = [payloads] if payloads.is_a?(Hash)

        payloads.each do |payload|
          if payload['channel'] && !settings.channels.include?(payload['channel'])
            settings.channels << payload['channel']
          end
        end

        settings.audiences.each do |audience|
          payloads.each do |payload|
            audience << "event: payload\n"
            audience << "data: #{payload.to_json}\n\n"
            p payload
          end
        end
        '{"result": true}'
      rescue JSON::ParseError
        halt 400
      end
    end
  end
end
