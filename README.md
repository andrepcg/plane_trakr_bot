![Logo](logo.png?raw=true "PlaneTrakrBot")

# PlaneTrakrBot

PlaneTrakrBot is a Telegram bot built with Ruby to send alerts when a airplane is found in ADS-B Exchange data

## Installation

```bash
bundle install
rake db:migrate
```

## Usage

```bash
./boot

# OR

ruby boot.rb
```

Set your Telegram Bot token with the `TELEGRAM_TOKEN` environment variable

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License
[MIT](https://choosealicense.com/licenses/mit/)