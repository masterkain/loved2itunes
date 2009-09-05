# Introduction

This Ruby script creates or overrides an iTunes playlist containing your loved last.fm tracks.

## Usage

    ruby loved2itunes.rb -h

## Examples

    ruby loved2itunes.rb -u kain82 -n MyLovedTracks --nv # will import loved tracks into MyLovedTracks playlist and excludes videos.
    ruby loved2itunes.rb -u kain82 # will import loved tracks into Loved playlist and includes videos.
    ruby loved2itunes.rb -u kain82 -nv -v # run verbosely, exclude videos

## Cronjob

This script is ideal to keep in sync with your last.fm loved tracks.
For example this will run hourly:

    01 * * * * /path/to/loved2itunes.rb -u username >/dev/null 2>&1

## Tips

You can also use another last.fm username and try to import the loved tracks of another person/account if you have the required files in your library.

## Resources

* [iCoreTech Research Labs](http://www.icoretech.org)
* [Original Announce](http://www.icoretech.org/2009/09/last-fm-loved-tracks-to-itunes/)
* [last.fm Message](http://www.last.fm/forum/21716/_/448880/2#f10474933)

[Claudio Poli]: http://www.icoretech.org

## Mac OS X installation

Tested on Snow Leopard.

Two gems are required in order to run loved2itunes, nokogiri and rb-appscript.

You will need Xcode installed since those gems requires compilation.

Open a terminal and issue those commands:

    sudo gem install nokogiri --no-rdoc --no-ri
    sudo gem install rb-appscript --no-rdoc --no-ri

## Windows installation

Tested on Windows XP SP3.

Download and install [Ruby](http://rubyforge.org/frs/download.php/29263/ruby186-26.exe).

Start a command prompt, Start -> Run -> cmd and press return

Issue those commands to update rubygems:

    Z:\src\loved2itunes>gem update --system
    Updating RubyGems...
    Attempting remote update of rubygems-update
    Install required dependency builder? [Yn]  y
    Install required dependency session? [Yn]  y
    Install required dependency hoe-seattlerb? [Yn]  y
    Install required dependency hoe? [Yn]  y
    Install required dependency rubyforge? [Yn]  y
    Install required dependency rake? [Yn]  y
    Install required dependency minitest? [Yn]  y
    Install required dependency hoe? [Yn]  y
    Successfully installed rubygems-update-1.3.5
    Successfully installed builder-2.1.2
    Successfully installed session-2.4.0
    Successfully installed hoe-seattlerb-1.2.1
    Successfully installed hoe-2.3.3
    Successfully installed rubyforge-1.0.4
    Successfully installed rake-0.8.7
    Successfully installed minitest-1.4.2
    Successfully installed hoe-2.3.3

Then install the required gem:

    Z:\src\loved2itunes>gem install nokogiri --no-rdoc --no-ri
    Successfully installed nokogiri-1.3.3-x86-mswin32
    1 gem installed
