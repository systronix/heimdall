# Heimdall

Heimdall is [Make Salt Lake](https://makesaltlake.org)'s access control system. It consists of a few different parts:

  - A web interface, written in Ruby on Rails. The rest of this README deals with the web interface.
  - A [component](backend) intended to run on an [ESP32](https://en.wikipedia.org/wiki/ESP32), one per door or other device that needs access control
  - A set of [printed circuit board designs](boards) that can be used to make the physical badge readers

## Local Environment Setup

First, clone Heimdall:

```shell
git clone git@github.com:makesaltlake/heimdall.git
cd heimdall
```

### Ruby

You'll need a [compatible](.ruby-version) Ruby version. [rbenv](https://github.com/rbenv/rbenv) is recommended, but plenty of other tools like [RVM](https://github.com/rvm/rvm) will work as well.

The easiest way to install rbenv is to use Homebrew. [Follow the directions](https://brew.sh/) to install Homebrew if you don't have it already, then install rbenv:

```shell
brew install rbenv
rbenv init
```

Close your terminal and open a new one to pick up the changes rbenv made to your `.bash_profile` or `.bashrc`. Then, inside your local clone of Heimdall, install Ruby:

```shell
rbenv install
```

There's a bug that sometimes causes rbenv to hang while waiting for the answer to a prompt that's never printed out. If you don't see any progress after a few minutes, type `y` and hit enter a few times.

Then install Bundler:

```shell
gem install bundler
```

### Node.js & Yarn

TBD

Install NVM, then `nvm install`, then `nvm use`, then `npm install -g yarn`, then `cd frontend && yarn`

### Postgres

Heimdall uses [Postgres](https://www.postgresql.org/) as its database.

On Mac, the easiest way to install Postgres is via Postgres.app. [Follow the instructions here](https://postgresapp.com/) to install it and create a new database server.

On Windows, [download Postgres directly](https://www.postgresql.org/download/) and install it, and create a database server if needed. (Yours Truly does not have a Windows machine handy, so you're on your own with this one.)

### Redis

[Redis](https://redis.io/) is used to synchronize [Action Cable](https://guides.rubyonrails.org/action_cable_overview.html) state between Heimdall servers and job workers.

On Mac, the easiest way to install Redis is via Homebrew:

```shell
brew install redis
```

On Windows, you'll want to [download and install it directly](https://redis.io/download).

By default, Heimdall will use database #5; if you're using that one for some other purpose, you'll want to `export REDIS_URL=redis://localhost/6` to use e.g. database #6 before starting Heimdall.

### Stripe

Make Salt Lake uses [Stripe](http://stripe.com/) to process membership dues. Heimdall integrates with Stripe to automatically create users for new members and deactivate badge access when a user cancels their membership. (Feel free to submit a PR if you're looking to use Heimdall and would like it to support another payment processor.)

Head on over to https://dashboard.stripe.com/register, create yourself an account, then go to your dashboard, grab your test mode secret key, and set it into an environment variable named `STRIPE_SECRET_KEY`.

Heimdall supports Stripe webhooks to proactively update membership information the moment something changes in Stripe. If you're making changes to the webhook code, you'll also want to [install the Stripe CLI and forward test webhook events](https://stripe.com/docs/webhooks/test) to your local Heimdall instance. When Stripe prints out your webhook signing secret (which will change every time you run `stripe listen`), you'll want to set it into an environment variable named `STRIPE_WEBHOOK_SECRET`.

### Ruby Dependencies

Install Heimdall's Ruby dependencies using Bundler. You'll want to do this every time you `git pull`.

```shell
bundle install
```

### Data Setup

First, create a database for Heimdall and populate it with the tables Heimdall needs:

```shell
bundle exec rake db:setup
```

This will also create a default admin user whose email is `admin@example.com` and whose password is `password`.

After you've done that once, on future `git pull`s you'll want to instead do:

```shell
bundle exec rake db:migrate
```

to run migrations and update your database with anything that's changed without blowing it away and starting from scratch every time.

At this point you're ready to fire up Heimdall and log in.

### It's Go Time

Open three terminal windows. In the first, start Heimdall's web server:

```shell
bundle exec rails server
```

Heimdall will listen on port 3000 by default. If you want it to listen on a different port, add `-p <port>` to the end of your command line.

Then, in the second terminal window, start a background job worker:

```shell
bundle exec inst_jobs run
```

And finally, in the third window, start the frontend development server:

```shell
cd frontend && yarn start
```

Then browse to http://localhost:3000, log in, and you're off to the races.

## Tests

Whoops - we kinda skipped writing tests when building Heimdall. There are a few and we're always adding more - help us out and code some up!

To run what we've got, you'll need to install Chrome and [ChromeDriver](https://chromedriver.chromium.org/). On Mac, you can snag it with `brew cask install chromedriver`. (Note that every time you upgrade to a new Chrome major version, you'll need to upgrade ChromeDriver with `brew cask upgrade chromedriver`.)

Then run the tests:

```shell
bundle exec rspec
```

## Deployment

TBD

## Contact

Join [Make Salt Lake's Slack team](https://slack.makesaltlake.org/), then head over to [#rfid-strikeforce](https://app.slack.com/client/T16JZCGBY/CGDLBCCCT) if you'd like to get in touch.
