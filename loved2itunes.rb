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

PVERSION = "1.3"
$KCODE = "u"

begin
  require 'rubygems'

  gem 'nokogiri', '>= 1.3.3'
  gem 'rb-appscript', '>= 0.5.3'

  require 'nokogiri'
  require 'appscript'
  require 'open-uri'
  include Appscript

  username       = ARGV[0] || 'kain82'
  playlist_name  = ARGV[1] || 'Loved'
  include_videos = ARGV[2] || 't'
  api_key        = ARGV[3] || API_KEY

  raise("please specify a username") if username.nil?

  puts "loved2itunes: #{PVERSION} running on Ruby #{RUBY_VERSION} (#{RUBY_PLATFORM}), initializing..."

  url = "http://ws.audioscrobbler.com/2.0/?method=user.getlovedtracks&user=#{URI.escape(username.downcase)}&api_key=#{api_key}&limit=0"
  doc = Nokogiri::XML(open(url))
  loved_tracks = (doc/'//lovedtracks/track') # XPath selection.

  iTunes = app("iTunes.app") # get iTunes reference.
  iTunes.launch unless iTunes.is_running? # run iTunes unless if it's already running.

  # Check if the playlist already exists, if it does, create a new one with the name provided.
  playlist = iTunes.playlists[playlist_name].exists ? iTunes.playlists[playlist_name] : iTunes.make(:new => :user_playlist, :with_properties => { :name => playlist_name })

  playlist.tracks.get.each{ |tr| tr.delete } # Reset playlist.

  puts "loved2itunes: found <#{loved_tracks.size}> loved tracks, importing..."

  counter, success, skipped = 0, 0, 0
  loved_tracks.each do |loved_track|
    counter += 1
    title = loved_track.search('name')[0].inner_html.to_s # Grab the name of the loved track.
    artist = loved_track.search('name')[1].inner_html.to_s # Grab the artist of the loved track.
    # Get a reference to the existing track from the main library.
    # This can return multiple references, sadly we can't check against album since last.fm APIs doesn't provide
    # this information.
    if include_videos == 't'
      track_ref = iTunes.library_playlists.first.tracks[its.artist.eq(artist).and(its.name.eq(title))]
    else
      track_ref = iTunes.library_playlists.first.tracks[its.artist.eq(artist).and(its.name.eq(title)).and(its.video_kind.eq(:none)).and(its.podcast.eq(false))]
    end

    # Check it track exists.
    if track_ref.exists
      iTunes.add(track_ref.location.get, :to => playlist) # Add the track to our playlist.
      success += 1
    else
      puts "loved2itunes: track <#{counter}/#{loved_tracks.size}> not found, skipping <#{title}>"
      skipped += 1
    end
  end

  puts "loved2itunes: <#{success}/#{loved_tracks.size}> tracks imported into '#{playlist_name}' playlist, #{skipped} skipped"
rescue Exception => e
  puts "loved2itunes: something went wrong, the error message is: #{e.message}"
ensure
  puts "loved2itunes: execution finished."
end
