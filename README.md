# Translator

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/Translator`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'httparty'
gem 'Translator', :git=>"https://github.com/lelo107/Translator"
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install Translator, :git=>"https://github.com/lelo107/Translator"

## Usage

```ruby
#in rails application console
Translator.debug_path = "#{Rails.root}/public/dump/"
pl = Translator.load_class(Translator.debug_last)
```
## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/Translator.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).


# EXAMPLE ##

pry

file = Translator.debug_last() #"20181121XD-backup2.LST.xml.lst_init.playlist"
pl = Translator.load_class(file)
Translator.export_lst(dest_file)



    params = "[{\"recon_uid\":\"140623665\",\"tx_id\":[\"OF95570-HDTX\",\"OF95570-HDTX-AU-POL\"],\"title\":\"Dc4#2326 DC-Cee Refresh Idents And Bumpers 5\\\" Blowing Flour\",\"title_2\":\"Dc4#2326 DC-Cee Refresh Idents And Bumpers 5\\\" Blowing Flour\",\"local_tx_time\":\"06:00:00:00\",\"prog_type\":\"\",\"schedule_event_type\":\"IDT\",\"event_type\":\"PRES\",\"component_type\":[\"Video\",\"Audio\"],\"tx_duration\":\"00:00:05:00\",\"timecode_in\":[\"11:25:00:00\",\"00:00:00:00\"]},{\"recon_uid\":\"140623666\",\"tx_id\":[\"SV82054-HDTX\",\"SV82054-HDTX-AU-ENG\",\"SV82054-HDTX-AU-POL\",\"SV82054-HDTX-EC-POL\"],\"title\":\"Lolirock Episode 20\",\"title_2\":\"Lolirock\",\"local_tx_time\":\"06:00:05:00\",\"prog_type\":\"Series\",\"schedule_event_type\":\"PROG\",\"event_type\":\"PROG\",\"component_type\":[\"Video\",\"Audio\",\"Audio\",\"Subtitles\"],\"tx_duration\":\"00:21:56:20\",\"timecode_in\":[\"10:00:00:00\",\"00:00:00:00\",\"00:00:00:00\",\"00:00:00:00\"]},{\"recon_uid\":\"140623669\",\"tx_id\":[\"FO23870-HDTX\",\"FO23870-HDTX-AU-POL\"],\"title\":\"Dc4 Dc2898 January Now Next Laters Corrected\",\"title_2\":\"Dc4 Dc2898 January Now Next Laters Corrected\",\"local_tx_time\":\"06:22:01:20\",\"prog_type\":\"\",\"schedule_event_type\":\"NAV\",\"event_type\":\"PRES\",\"component_type\":[\"Video\",\"Audio\"],\"tx_duration\":\"00:00:05:00\",\"timecode_in\":[\"10:00:00:00\",\"00:00:00:00\"]},{\"recon_uid\":\"140623670\",\"tx_id\":[\"FO28157-HDTX\",\"FO28157-HDTX-AU-POL\"],\"title\":\"Dc4#3066 Rolling With The Ronks - Sustain\",\"title_2\":\"Dc4#3066 Rolling With The Ronks - Sustain\",\"local_tx_time\":\"06:22:06:20\",\"prog_type\":\"\",\"schedule_event_type\":\"PRO\",\"event_type\":\"PROM\",\"component_type\":[\"Video\",\"Audio\"],\"tx_duration\":\"00:00:30:00\",\"timecode_in\":[\"10:01:00:00\",\"00:00:00:00\"]},{\"recon_uid\":\"140623671\",\"tx_id\":[\"FO28111-HDTX\",\"FO28111-HDTX-AU-POL\"],\"title\":\"Dc4#3064 Miraculous: Tales Of Ladybug And Cat Noir New Eps (August)\",\"title_2\":\"Dc4#3064 Miraculous: Tales Of Ladybug And Cat Noir New Eps (August)\",\"local_tx_time\":\"06:22:36:20\",\"prog_type\":\"\",\"schedule_event_type\":\"PRO\",\"event_type\":\"PROM\",\"component_type\":[\"Video\",\"Audio\"],\"tx_duration\":\"00:00:30:00\",\"timecode_in\":[\"10:00:00:00\",\"00:00:00:00\"]},{\"recon_uid\":\"140623672\",\"tx_id\":[\"OF87623-HDTX\",\"OF87623-HDTX-AU-POL\"],\"title\":\"Dc4#3610 Refresh Commercial Bumpers - Reklama In 1 (5secs)\",\"title_2\":\"Dc4#3610 Refresh Commercial Bumpers - Reklama In 1 (5secs)\",\"local_tx_time\":\"06:23:06:20\",\"prog_type\":\"\",\"schedule_event_type\":\"BCI\",\"event_type\":\"PRES\",\"component_type\":[\"Video\",\"Audio\"],\"tx_duration\":\"00:00:05:00\",\"timecode_in\":[\"10:04:00:00\",\"00:00:00:00\"]},{\"recon_uid\":\"170515191\",\"tx_id\":[\"DC145473WS\",\"DC145473WS-TX-AU-POL\"],\"title\":\"Play doh dentysta\",\"title_2\":\"DC145473WS\",\"local_tx_time\":\"06:23:11:20\",\"prog_type\":\"\",\"schedule_event_type\":\"COM\",\"event_type\":\"COMM\",\"component_type\":[\"Video\",\"Audio\"],\"tx_duration\":\"00:00:15:00\",\"timecode_in\":[\"00:00:00:00\",\"00:00:00:00\"]}]"


    @lst = JSON.parse(params)

    error=nil
    Translator::NEW_LOGO["tx_id"][0] = "ICONX"
      


    playlist = Translator::Playlist.new(array: @lst,branding_active: true,logo_active: false,promo_active: true,commercial_active: false,iconx: true,v12: true,local_branding: true)      

    file = "outputs/file.lst"
    playlist.export_lst(file)


	local debug
	Translator.debug_path="/Users/lello107/GEMME/Translator/bin/public/dump/"

	pl = Translator.load_class(Translator.list_stored_class[1][:playlist])

	pl.branding = Translator::Branding.new(pl.playlist, true, false)

