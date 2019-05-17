# Customer Service Portal
ReCharge Checkout API web interface for [Shopify](https://www.shopify.com/)

[![Maintainability](https://api.codeclimate.com/v1/badges/3c0a827712ad8431c695/maintainability)](https://codeclimate.com/github/Nevillealee/cs_prepaid_app/maintainability)

Updates Prepaid Subscriptions through easy-to-use GUI. Features Administrative User functionality,
asynchronous API -> database syncing via batching, and a browser compatible background job monitoring.

## Installation

### Prerequisites

First, make sure you have these dependencies installed on your local machine

* Ruby 2.6.0
* postgresql
* nodejs
* rvm (suggested)
* Redis
* Bundler

### Set up repo

Next, clone this repository onto your local machine
```
git clone https://github.com/Nevillealee/cs_prepaid_app.git
```

Change into newly created directory
```
cd cs_prepaid_app
```

Install gems
```
bundle
```

Create env file (in app root dir) with DATABASE_URL, DEFAULT_MASTER_USER_EMAIL, RECHARGE_TOKEN
```
touch .env
```
### Set up database

Create database
```
rake db:create
```

Load schema file (dont run migrations)
```
rake db:schema:load
```

### Set up initial admin User (Only admins can create new users)

Edit db/seeds.rb
```
(linux) sudo nano db/seeds.rb or edit in your IDE
```

Seed the database
```
rake db:seed
```

### Populate Data

Pull data from ReCharge
```
rake batch_mass_request
```

Upsert data into Postgres
```
rake batch_mass_upsert
```

## Start the app

In a new terminal
```
rails s
```

Then in a second terminal tab
```
QUEUE=* rake resque:work
```

Last, leave a third terminal open for rake task commands

## Usage example

A few motivating and useful examples of how your product can be used. Spice this up with code blocks and potentially more screenshots.

_For more examples and usage, please refer to the [Wiki][wiki]._


## Release History

* v1.0.0-beta
    * Work in progress

## Meta

* **Neville Lee** - [https://github.com/nevillealee/cs_prepaid_app](https://github.com/nevillealee/cs_prepaid_app)
* **David Kim** - [https://github.com/dhkim1211](https://github.com/dhkim1211)

## Contributing

1. Fork it (<https://github.com/yourname/yourproject/fork>)
2. Create your feature branch (`git checkout -b feature/fooBar`)
3. Commit your changes (`git commit -am 'Add some fooBar'`)
4. Push to the branch (`git push origin feature/fooBar`)
5. Create a new Pull Request
