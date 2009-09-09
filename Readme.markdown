# Introduction

This Ruby script creates or overrides an iTunes playlist containing your loved last.fm tracks.

## Usage

    ruby loved2itunes.rb -h

## Examples

    ruby loved2itunes.rb -u kain82 -n MyLovedTracks -e # will import loved tracks into MyLovedTracks playlist and excludes videos.
    ruby loved2itunes.rb -u kain82 # will import loved tracks into Loved playlist and includes videos.
    ruby loved2itunes.rb -u kain82 -e -v # run verbosely, exclude videos

## Cronjob

This script is ideal to keep in sync with your last.fm loved tracks.
For example this will run hourly:

    01 * * * * /path/to/loved2itunes.rb -u username

## Tips

You can also use another last.fm username and try to import the loved tracks of another person/account if you have the required files in your library.

## Resources

* [iCoreTech Research Labs](http://www.icoretech.org)
* [Original Announce](http://www.icoretech.org/2009/09/last-fm-loved-tracks-to-itunes/)
* [last.fm Message](http://www.last.fm/forum/21716/_/448880/2#f10474933)

[Claudio Poli]: http://www.icoretech.org

## Mac OS X installation

Tested on Snow Leopard with iTunes:
- 8.2.6
- 9.0

Two rubygems are required in order to run loved2itunes, nokogiri and rb-appscript.

Open a terminal and issue those commands:

    sudo gem install nokogiri --no-rdoc --no-ri
    sudo gem install rb-appscript --no-rdoc --no-ri

Run the script as described above.

## Windows installation

This is an experimental feature.

Tested on Windows XP SP3 with iTunes:
- 8.2.6

Download and install [Ruby](http://rubyforge.org/frs/download.php/29263/ruby186-26.exe).

After the installation completes, start a command prompt, Start -> Run -> write cmd and press return.

Issue those commands to update rubygems:

    gem update --system

Then install the required gem:

    gem install nokogiri --no-rdoc --no-ri

Run the script as described above.