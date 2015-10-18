# WepaExtractor

*Web Page Extractor - currently in heavily development - do not use this
gem yet:)*

Based of metadata parse web page(s) and return extracted informatin.

Use case:
* parse produkt page on shop portal and return table of detail.
* obtain all documents with metadata form city hall (e.g. meeting
   minutes, agenda, etc.) in machine-readable form.

This gem needs "metadata" information which describes how the page has
to be parsed.



## Installation

Add this line to your application's Gemfile:

```ruby
gem 'wepa_extractor'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install wepa_extractor

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/lksv/wepa_extractor.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

