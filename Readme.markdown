# Introduction

This Ruby script creates or overrides an iTunes playlist containing your loved last.fm tracks.
Tested on Snow Leopard, iTunes 8.2.1 running Ruby 1.8.7 and created by [Claudio Poli](http://www.workingwithrails.com/person/7834-claudio-poli).

## Requirements

Two gems are required in order to run loved2itunes, nokogiri and rb-appscript.
You will need Xcode installed since those gems requires compilation.
Install as follow:

    sudo gem install nokogiri
    sudo gem install rb-appscript

## Usage

    ruby loved2itunes.rb username [playlist_name] [include_videos] [api_key]

Please note that api\_key and playlist\_name are optional, the latter, if not specified, will make the script use '__Loved__' as playlist name.
Option include\_videos is a boolean and takes only 't' or 'f'. Actually the operation if much faster when including videos, due to iTunes taking its time to filter out video stuff.
Also note that when you have duplicates, the script will put them all in your playlist, it can't check if the song is from a different album due to last.fm API limitations.

## Examples

    ruby loved2itunes.rb kain82 MyLovedTracks f # will import loved tracks into MyLovedTracks playlist and excludes videos.
    ruby loved2itunes.rb kain82 Loved t # will import loved tracks into Loved playlist and includes videos.

## Resources

* [iCoreTech Research Labs](http://www.icoretech.org)
* [Original Announce](http://www.icoretech.org/2009/09/last-fm-loved-tracks-to-itunes/)
* [last.fm Message](http://www.last.fm/forum/21716/_/448880/2#f10474933)

[Claudio Poli]: http://www.icoretech.org