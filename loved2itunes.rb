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

# Create or override a new playlist from your loved last.fm tracks to iTunes.
# Tested on Snow Leopard.

# Usage:
#   ruby loved2itunes.rb username playlist_name

# You need to install Xcode and two gems:
#   sudo gem install nokogiri
#   sudo gem install rb-appscript

$KCODE = "u"

require 'rubygems'
require 'open-uri'
require 'nokogiri'
require 'appscript'

username      = ARGV.first
playlist_name = ARGV[1] || 'Loved'

begin
  # Using the api keys found in the docs, replace with yours if you feel.
  url = "http://ws.audioscrobbler.com/2.0/?method=user.getlovedtracks&user=#{username}&api_key=b25b959554ed76058ac220b7b2e0a026&limit=0"
  doc = Nokogiri::XML(open(url))
  # XPath selection, can be vastly improved.
  loved_tracks = (doc/'//lovedtracks')./('track')

  # get iTunes reference.
  iTunes = Appscript.app("iTunes.app")
  # run iTunes unless if it's already running.
  iTunes.run unless iTunes.is_running?

  # Check if the playlist already exists, if it does, create a new one with the name provided.
  playlist = iTunes.playlists[playlist_name].exists ? iTunes.playlists[playlist_name] : iTunes.make(:new => :user_playlist, :with_properties => { :name => playlist_name })
  # Reset playlist.
  playlist.tracks.get.each{ |tr| tr.delete } if playlist.tracks.get.size.to_i > 0

  loved_tracks.each do |loved_track|
    # Grab the name of the loved track.
    title = loved_track.search('name')[0].inner_html.to_s
    # Get a reference to the existing track, it may be more robust in future.
    track_ref = iTunes.library_playlists[1].tracks[title]
    # Finally add the track to our playlist.
    iTunes.add(track_ref.location.get, :to => playlist) if track_ref.exists
  end
rescue Exception => e
  puts "Something was wrong: #{e.message}"
end
