![Logo](logo.png?raw=true "PlaneTrakrBot")

# PlaneTrakrBot

PlaneTrakrBot is a Telegram bot built with Ruby to send alerts when a airplane is found in ADS-B Exchange data

## Installation

```bash
bundle install
rake db:migrate
```

## Usage

Set your Telegram Bot token with the `TELEGRAM_TOKEN` environment variable.

### To start the bot:

```bash
./boot

# OR

ruby boot.rb
```

### To send out alerts:

Add the following command to Cron or similar tool.

`bundle exec rake alerts:process`.

Currently, the time needed for an alert to retrigger is hardcoded in the [Alert model](https://github.com/andrepcg/plane_trakr_bot/blob/3d8b81cf91d3f997d5b3ca941088bba55c629701/app/models/alert.rb#L4).

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License
[MIT](https://choosealicense.com/licenses/mit/)
