require 'thread'
require 'optparse'
require 'net/http'
require 'uri'
require 'json'

module Listenize
  class CLI
    def self.run(*args)
      self.new(*args).run
    end

    def initialize(argv)
      @argv = argv.dup
      @options = parse_option
    end

    def run
      if @options[:stop]
        send(channel: @options[:channel], stop: true)
        return 0
      end

      if @options[:chars]
        queue = Queue.new
        th = Thread.new() do
          while is = queue.pop
            send(is.map { |i| {channel: @options[:channel], time: @options[:time], t: [*@argv, i]} })
          end
        end
        while l = $stdin.gets
          puts l if @options[:tee]
          queue.push(l.chars.map{ |c| c.ord * 10 })
        end
        queue.push(nil)
        th.join
      else
        send(channel: @options[:channel], time: @options[:time], t: @argv.map{ |x| /^[\d]+(\.\d+)?$/ === x ? x.to_f : x })
      end
      0
    end

    private

    def parse_option
      options = {
        uri: URI.parse("http://localhost:8959/api/bulk"),
        channel: 'listenizer', time: 500
      }

      OptionParser.new do |op|
        op.on('-h uri', 'URL for listenizer') do |val|
          options[:uri] = URI.parse(val) + "/api/bulk"
        end

        op.on('-c channel', 'Channel to play') do |val|
          options[:channel] = val
        end

        op.on('-t time', 'Time to play (milliseconds)') do |val|
          options[:time] = val.to_i
        end

        op.on('--forever', 'Play forever') do
          options[:time] = nil
        end

        op.on('--stop', 'Stop playing') do
          options[:stop] = true
        end

        op.on('--chars', 'Listenize STDIN, sound will be hear per line') do
          options[:chars] = true
        end

        op.on('--tee', 'When --chars, puts read lines into stdout') do
          options[:tee] = true
        end
      end.parse!(@argv)
      options
    end

    def send(data)
      Net::HTTP.start(@options[:uri].host, @options[:uri].port) do |http|
        http.post(@options[:uri].path, data.to_json)
      end
    end
  end
end



