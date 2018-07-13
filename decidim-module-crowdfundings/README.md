# Decidim::Crowdfundings

This rails engine implements a Decidim component that allows to the administrators
to configure crowfunding campaigns for a participatory space.

## Usage

This plugin provides:

* A CRUD engine to manage crowfunding campaigns.

* Public views for crowfunding campaigns via a menu inside each participatory space.

* An interface with Census API.

* Rake tasks necessary to automatize recurrent payments.

## Installation

Add the following lines to your application's Gemfile:

```ruby
gem 'decidim-crowdfundings'
```

And then execute:

```bash
bundle
bundle exec rails decidim_crowdfundings:install:migrations
bundle exec rails db:migrate
bundle exec rails generate decidim:crowdfundings:install
```

Then you'll need to configure the environment variable CENSUS_URL to point to
the running instance of [census].

## Tests

In order to execute the tests data from iban_bic gem must be populated as well:

```bash
bundle exec rails db:migrate RAILS_ENV=test
```

## Docker & Docker compose

This engine is supplied with Docker compose files. If you want to use them you
need to check the *spec/decidim_dummy_app/database.yml* and adjust the database
settings:

```yaml
default: &default
  adapter: postgresql
  encoding: unicode
  # For details on connection pooling, see rails configuration guide
  # http://guides.rubyonrails.org/configuring.html#database-pooling
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  host: <%= ENV.fetch("DATABASE_HOST") { "db" } %>
  username: <%= ENV.fetch("DATABASE_USERNAME") { "admin" } %>
  password: <%= ENV.fetch("DATABASE_PASSWORD") { "admin" } %>
```

If you desire to use different settings you need to check the Docker compose
settings and adjust the setup of the PostgreSQL image.

Finally remember that the Docker file do not includes any command relative to
the database setup. Due to this limitation, the first time that you execute the
app you must execute the following commands:

```bash
docker-compose run web bash
cd spec/decidim_dummy_app
bundle exec rails db:create
bundle exec rails db:migrate
bundle exec rails db:seed
```

## Rake tasks

This engine provides the following rake tasks:

### decidim_crowdfundings:recurrent_contributions

This task collects all recurrent contributions that need to be renewed. Ideally
it should be automatically executed at least once per month.

### decidim_crowdfundings:update_status

This task collects all contributions in pending status. Then proceeds querying
Census about the payment method status. According to Census response the
contribution payment will be accepted or rejected. This process should be executed
several times per month, ideally on periods of low load. It should be executed
at least once before the *decidim_crowdfundings:recurrent_contributions* is
executed.

## License

This engine is distributed under the GNU AFFERO GENERAL PUBLIC LICENSE.

[census]: https://github.com/podemos-info/census
