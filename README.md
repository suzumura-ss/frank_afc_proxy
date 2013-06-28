# FrankAfcProxy

Connect to FrankServer with iPhone USB cable via afc.


## Installation

Required gem io_afc, and libimobiledevice version 1.1.5 or later.

Add this line to your application's Gemfile:

    gem 'frank_afc_proxy'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install frank_afc_proxy


## Usage


1. First, run frank setup In your application project directory.

        $ frank setup

2. And install frankAfcProxy into your application.

        $ frankAfcProxy-install

3. Build and launch your application with fruitstrap.

  http://www.testingwithfrank.com/device.html

4. Start frankAfcProxy with your application bundle identifer.

        $ frankAfcProxy start --appid=<bundle identifer>

  You can check bundle identifiers in the following ways.

        $ frankAfcProxy list

5. Run frank console with --server option.

        $ frank console --server=http://localhost:4000/

  Or, Run test with server_base_url settings.

        Frank::Cucumber::FrankHelper.server_base_url = "http://localhost:4000/"

6. Access to device with FrankHelper.



## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
