# Introduction

This ruby script creates or overrides an iTunes playlist containing your loved last.fm tracks.
Tested on Snow Leopard, iTunes 8.2.1 running Ruby 1.8.7 and it's created by [Claudio Poli][]

# Requirements

Two gems are required in order to run loved2itunes, nokogiri and rb-appscript.
You will need Xcode installed since those gems requires compilation.
Install as follow:

    sudo gem install nokogiri
    sudo gem install rb-appscript

# Usage

    ruby loved2itunes.rb username [playlist_name] [api_key]

Please note that api\_key and playlist\_name are optional, the latter, if not specified, will make the script use '__Loved__' as playlist name.

[Claudio Poli]: http://www.icoretech.org