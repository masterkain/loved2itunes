#!/usr/bin/env ruby
#--
# Copyright (c) 2009 Claudio Poli
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++

API_KEY = "b25b959554ed76058ac220b7b2e0a026"
PVERSION = "1.4"

$KCODE = "u"

require 'rubygems'
require 'open-uri'
require 'nokogiri'
require 'optparse'
require 'ostruct'
require 'pp'

if RUBY_PLATFORM =~ /mswin|mingw/
  require 'win32ole'
elsif PLATFORM =~ /darwin/
  require 'appscript'
else
  raise("Unsupported operating system.")
end

class ParseOptions

  def self.parse(args)
    options = OpenStruct.new
    options.no_video      = false
    options.api_key       = API_KEY
    options.limit         = 0
    options.playlist_name = 'Loved'

    opts = OptionParser.new do |opts|
      opts.banner = "Usage: #{$0} [options]"

      opts.separator " "
      opts.separator "Mandatory options:"

      opts.on("-u", "--username=name", String, "Specifies the last.fm username for the script to operate on.") { |u| options.username = u }

      opts.separator " "
      opts.separator "Specific options:"

      opts.on("-n", "--playlist_name", String, "Specifies the playlist name, if not 'Loved' will be used instead.") { |n| options.playlist_name = n }
      opts.on("-nv", "--no_video", "If present specifies to exclude videos (slowing operations).") { |i| options.no_video = i }
      opts.on("-a", "--api_key=key", String, "Specifies the last.fm api key for the script to operate.") { |a| options.api_key = a }
      opts.on("-l", "--limit=name", Integer, "Specifies how many tracks you want to fetch.") { |l| options.limit = l }
      opts.on("-v", "--[no-]verbose", "Run verbosely") { |v| options.verbose = v }

      opts.separator " "

      opts.separator "Common options:"
      opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
      end

      opts.on_tail("--version", "Show version") do
        puts PVERSION
        exit
      end
    end # end OptionParser

    opts.parse!(args)
    options
  end # end parse()

end # end class ParseOptions

options = ParseOptions.parse(ARGV)
begin
  if options.username.nil?
    $stderr.puts "Please run '#{$0} -h' for help."
    exit 1
  else
    puts "loved2itunes: #{PVERSION} running on Ruby #{RUBY_VERSION} (#{RUBY_PLATFORM}), initializing..." if options.verbose

    url = "http://ws.audioscrobbler.com/2.0/?method=user.getlovedtracks&user=#{URI.escape(options.username.downcase)}&api_key=#{options.api_key}&limit=0"
    doc = Nokogiri::XML(open(url))
    loved_tracks = (doc/'//lovedtracks/track') # XPath selection.

    if PLATFORM =~ /darwin/
      # Operating on Macintosh.
      iTunes = Appscript.app("iTunes.app") # get iTunes reference.
      iTunes.launch unless iTunes.is_running? # run iTunes unless if it's already running.

      # Check if the playlist already exists, if it does, create a new one with the name provided.
      playlist = iTunes.playlists[options.playlist_name].exists ? iTunes.playlists[options.playlist_name] : iTunes.make(:new => :user_playlist, :with_properties => { :name => options.playlist_name })
      playlist.tracks.get.each{ |tr| tr.delete } # Reset playlist.

      puts "loved2itunes Mac: found <#{loved_tracks.size}> loved tracks, trying to import..." if options.verbose

      counter, success, skipped, whose = 0, 0, 0, Appscript.its
      loved_tracks.each do |loved_track|
        counter += 1
        title  = loved_track.search('name')[0].inner_html.to_s # Grab the name of the loved track.
        artist = loved_track.search('name')[1].inner_html.to_s # Grab the artist of the loved track.
        # Get a reference to the existing track from the main library.
        # This can return multiple references, sadly we can't check against album since last.fm APIs doesn't provide
        # this information.
        if options.no_video
          track_ref = iTunes.library_playlists.first.tracks[whose.artist.eq(artist).and(whose.name.eq(title)).and(whose.video_kind.eq(:none)).and(whose.podcast.eq(false))]
        else
          track_ref = iTunes.library_playlists.first.tracks[whose.artist.eq(artist).and(whose.name.eq(title))]
        end

        # Check it track exists.
        if track_ref.exists
          iTunes.add(track_ref.location.get, :to => playlist) # Add the track to our playlist.
          success += 1
        else
          puts "loved2itunes Mac: track <#{counter}/#{loved_tracks.size}> not found, skipping <#{title}>" if options.verbose
          skipped += 1
        end
      end
      puts "loved2itunes Mac: <#{success}/#{loved_tracks.size}> tracks imported into '#{options.playlist_name}' playlist, #{skipped} skipped" if options.verbose

    else
      # Operating on Windows.
      iTunes = WIN32OLE.new('iTunes.Application')

      # Destroy and recreate playlist.
      iTunes.LibrarySource.Playlists.ItemByName(options.playlist_name).delete
      playlist = iTunes.CreatePlaylist(options.playlist_name)

      puts "loved2itunes Win: found <#{loved_tracks.size}> loved tracks, trying to import..." if options.verbose

      counter, success, skipped = 0, 0, 0
      loved_tracks.each do |loved_track|
        counter += 1
        title  = loved_track.search('name')[0].inner_html.to_s # Grab the name of the loved track.
        artist = loved_track.search('name')[1].inner_html.to_s # Grab the artist of the loved track.
        # Get a reference to the existing track from the main library.
        # This can return multiple references, sadly we can't check against album since last.fm APIs doesn't provide
        # this information.
        if options.include_video
          track_ref = iTunes.LibraryPlaylist.Tracks.ItemByName(title) || nil
        else
          track_ref = iTunes.LibraryPlaylist.Tracks.ItemByName(title) || nil
        end
        # Check it track exists.
        unless track_ref.nil?
          playlist.AddTrack(track_ref) # Add the track to our playlist.
          success += 1
        else
          puts "loved2itunes Win: track <#{counter}/#{loved_tracks.size}> not found, skipping <#{title}>" if options.verbose
          skipped += 1
        end
      end
      puts "loved2itunes Win: <#{success}/#{loved_tracks.size}> tracks imported into '#{options.playlist_name}' playlist, #{skipped} skipped" if options.verbose

    end

  end

end
