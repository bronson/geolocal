# Geocode::Static

Allows IP address geocoding to be performed in a single Ruby if statement.  It
makes checking whether an IP address is in a country or a continent is as easy
as calling `addr.in_EU?`.  No network access, no context switches.


## Installation

The usual methods.  Adding this line to your Gemfile is probably best:

    gem 'geocode-static'


## Usage

Run the executable to create a blank configuration file.

    $ geocode-static init

Fill it in, then run this command to generate the if statements
for your regions:

    $ geocode-static update

That's it!


## Contributing

To make this gem less imperfect, please submit your changes on GitHub
as a pull request.
